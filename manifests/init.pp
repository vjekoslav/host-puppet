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
        '--log-driver=gelf',
        '--log-opt gelf-address=udp://172.17.42.1:12201',
        '--name=dns',
    ],
    command => "--domain docker --resolver ${::ipaddress_eth0} 8.8.8.8",
    require => Docker::Image['phensley/docker-dns'],
    manage_service => false,
}

docker::run { 'apt-cacher':
    image => 'sameersbn/apt-cacher-ng',
    restart => 'always',
    use_name => true,
    expose => ['3142'],
    volumes => ['/srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng'],
    extra_parameters => [
        '--log-driver=gelf',
        '--log-opt gelf-address=udp://172.17.42.1:12201',
        '--name=apt-cacher',
    ],
    require => Docker::Image['sameersbn/apt-cacher-ng'],
    manage_service => false,
}

#docker run --log-driver=gelf --log-opt gelf-address=udp://<GraylogIP>:12201 busybox echo Hello Graylog
docker::run { 'graylog2':
    image => 'graylog2/allinone',
    restart => 'always',
    use_name => true,
    ports => ['9000:9000', '172.17.42.1:12201:12201/udp'],
    volumes => ['/srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng'],
    extra_parameters => [
        '-t',
        '--name=graylog2',
    ],
    #env => [ 'GRAYLOG_PASSWORD=Secunia1' ],
    require => Docker::Image['graylog2/allinone'],
    manage_service => false,
}