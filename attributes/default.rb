default[:server][:data_volume][:disk_count]    = 2
default[:server][:data_volume][:disk_size]     = 10
default[:server][:data_volume][:raid_level]    = 1
default[:server][:data_volume][:filesystem]    = "ext4"
default[:server][:data_volume][:disk_type]     = "standard"
default[:server][:data_volume][:disk_piops]    = 0 #since the default is a standard disk
default[:server][:data_volume][:ebs_device]    = "/dev/sdi"
default[:server][:data_volume][:system_device] = "/dev/xvdi"
default[:server][:data_volume][:raid]          = false #True if the data volume would be a RAID volume
default[:server][:data_volume][:raid_device]   = "/dev/md0"

default[:server][:domain]                      = "local"
default[:server][:hostname]                    = "server"

default[:server][:swap][:size]                 = 2048