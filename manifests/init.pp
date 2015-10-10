$user = 'vjeko'

apt::ppa { 'ppa:webupd8team/sublime-text-3': }
apt::ppa { 'ppa:webupd8team/java': }

class { 'apt':
    update => {
        frequency => 'always',
    }
} -> Package <| |>

package{ 'default-jdk':
    require => Class['apt']
}

package{ 'tmux': }
package{ 'dnsutils': }
package{ 'htop': }
package{ 'wget': }
package{ 'curl': }
package{ 'aptitude': }
package{ 'python-pip': }
package{ 'sublime-text-installer':
    require => Class['apt']
}

# archive { 'ideaIU-15-preview':
#     ensure => present,
#     url    => 'https://download.jetbrains.com/idea/ideaIU-15-PublicPreview.tar.gz',
#     target => '/opt',
#     follow_redirects => true,
#     digest_string => '7c53817e966f162b2062c90c8159242a',
#     src_target => '/tmp'
# }

python::pip { 'docker-compose' :
    pkgname       => 'docker-compose',
    ensure        => '1.4.2',
    install_args  => ['-U'],
    require => Package['python-pip']
}

ohmyzsh::install{ $user:
    set_sh => true,
}
ohmyzsh::theme{ $user:
    theme => 'agnoster'
}
ohmyzsh::plugins{ $user: 
    plugins => 'git github tmux' 
}

# replace with hiera
include git
git::config { 'user.name':
    value => 'Vjekoslav Nikolic',
    user => $user,
}
git::config { 'user.email':
    value => 'vjeko.nikolic@gmail.com',
    user => $user,
}
git::config { 'push.default':
    value => 'simple',
    user => $user,
}

class { 'docker':
    # Setup docker containers to have chaing of DNS
    dns => [ '172.17.42.1', '8.8.8.8' ],
    dns_search => 'docker',
    docker_users => [ $user ],
}

# TODO: networkmanager /etc/NetworkManager/dnsmasq.d/10-docker interface=eth0 server=/docker/172.17.42.1#53

# fetch images
docker::image { 'phensley/docker-dns': }
docker::image { 'sameersbn/apt-cacher-ng': }
docker::image { 'graylog2/allinone': }

docker::run { 'dns':
  image => 'phensley/docker-dns',
  restart => 'always',
  use_name => true,
  ports => ['172.17.42.1:53:53/udp'],
  volumes => ['/var/run/docker.sock:/docker.sock'],
  extra_parameters => [
    '--log-opt max-size=5k',
    '--log-opt max-file=10',
    '--name=dns',
  ],
  command => "--domain docker --resolver ${::ipaddress_eth0} 8.8.8.8",
  require => Docker::Image['phensley/docker-dns'],
  manage_service => false,
}