Vagrant.configure("2") do |config|
  config.vm.box = "rocky9-vbox-direct"
  config.vm.box_url = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Vagrant-Vbox-9.8-20260525.0.x86_64.vagrant.virtualbox.box"

  config.ssh.insert_key = true

  # Security/cleanliness: do not mount the project folder inside every VM.
  # Ansible will manage the machines over SSH instead.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  nodes = [
    { name: "ha01",  ip: "192.168.56.11", memory: 1280, cpus: 1 },
    { name: "ha02",  ip: "192.168.56.12", memory: 1280, cpus: 1 },
    { name: "ha03",  ip: "192.168.56.13", memory: 1280, cpus: 1 },
    { name: "app01", ip: "192.168.56.21", memory: 768,  cpus: 1 },
    { name: "app02", ip: "192.168.56.22", memory: 768,  cpus: 1 }
  ]

  nodes.each do |machine|
    config.vm.define machine[:name] do |node|
      node.vm.hostname = machine[:name]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.provision "file",
        source: "assets/ssh/lab_ed25519.pub",
        destination: "/tmp/lab_ed25519.pub"
      node.vm.provision "file",
        source: "bootstrap/bootstrap.sh",
        destination: "/tmp/bootstrap.sh"
      node.vm.provision "shell", inline: <<-SHELL
        chmod u+x /tmp/bootstrap.sh
        /tmp/bootstrap.sh
      SHELL

      node.vm.provider "virtualbox" do |vb|
        vb.name = "secure-ha-#{machine[:name]}"
        vb.memory = machine[:memory]
        vb.cpus = machine[:cpus]
        vb.gui = false
      end
    end
  end
end