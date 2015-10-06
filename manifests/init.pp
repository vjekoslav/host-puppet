$user = 'vjeko'

apt::ppa { 'ppa:webupd8team/sublime-text-3': }
apt::ppa { 'ppa:webupd8team/java': }
class { 'apt':
  update => {
    frequency => 'always',
  },
}

package{ 'tmux': }
package{ 'htop': }
package{ 'wget': }
package{ 'curl': }
package{ 'sublime-text-installer': }

ohmyzsh::install{ 'vjeko':
    set_sh => true,
}
ohmyzsh::theme{ 'vjeko':
    theme => 'agnoster'
}
ohmyzsh::plugins{ 'vjeko': 
    plugins => 'git github tmux' 
}

# replace with hiera
include git
git::config { 'user.name':
  value => 'Vjekoslav Nikolic',
  user => 'vjeko',
}
git::config { 'user.email':
  value => 'vjeko.nikolic@gmail.com',
  user => 'vjeko',
}
git::config { 'push.default':
  value => 'simple',
  user => 'vjeko',
}