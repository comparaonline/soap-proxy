# -*- mode: ruby -*-
# vi: set ft=ruby :
# sublime: x_syntax Packages/Ruby/Ruby.tmLanguage

Vagrant.configure(2) do |config|

  config.vm.define :soap_proxy do |dev|

    memory = 256
    cpus = 1
    box = "ubuntu/trusty32"
    dev.vm.box = box

    dev.vm.hostname = 'soap-proxy.dev'
    dev.vm.network :private_network, ip: '192.168.33.50'
    dev.vm.synced_folder ".", "/vagrant", type: "nfs"

    dev.ssh.forward_agent = true

    
    dev.vm.provider "virtualbox" do |vb|
      vb.memory = memory
      vb.cpus = cpus
      vb.name = 'soap_proxy'
    end
    dev.vm.provider "vmware_fusion" do |vw|
      vw.vmx["memsize"] = memory.to_s
      vw.vmx["numvcpus"] = cpus.to_s
      vw.box = box
    end

    config.vm.provision "shell", path: 'setup.sh'

  end

end
