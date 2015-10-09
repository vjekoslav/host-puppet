$user = 'vjeko'

apt::ppa { 'ppa:webupd8team/sublime-text-3': }
apt::ppa { 'ppa:webupd8team/java': }

apt::source { 'docker-stable':
    location => 'https://apt.dockerproject.org/repo',
    release => 'ubuntu-trusty',
    repos => 'main',
    key => {
        id => '58118E89F3A912897C070ADBF76221572C52609D',
        server => 'hkp://p80.pool.sks-keyservers.net:80',
    },
}

class { 'apt':
    update => {
        frequency => 'always',
    }
} -> Package <| |>

package{ 'default-jdk':
    require => Apt::Ppa['ppa:webupd8team/java']
}

package{ 'tmux': }
package{ 'dnsutils': }
package{ 'htop': }
package{ 'wget': }
package{ 'curl': }
package{ 'aptitude': }
package{ 'python-pip': }
package{ 'sublime-text-installer':
    require => Apt::Ppa['ppa:webupd8team/sublime-text-3']
}
package{ 'docker-engine':
    require => Apt::Source['docker']
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

# class { 'docker':
#     # Setup docker containers to have chaing of DNS
#     dns => ["<%= scope.lookupvar('::ipaddress_docker_0') -%>", '8.8.8.8'],
#     dns_search => 'docker',
#     docker_users => [ $user ],
#     require => Package['docker-engine'],

# }
