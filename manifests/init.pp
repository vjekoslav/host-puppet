# execute 'apt-get update'
exec { 'apt-update':
    command => '/usr/bin/apt-get update'
}

package{ 'tmux': }
package{ 'htop': }
package{ 'wget': }
package{ 'curl': }

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
}
git::config { 'user.email':
  value => 'vjeko.nikolic@gmail.com',
}
