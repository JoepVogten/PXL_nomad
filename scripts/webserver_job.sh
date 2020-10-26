sudo mkdir /opt/nomad
sudo cat << END >/opt/nomad/job.nomad
job "webserver" {
  datacenters = ["dc1"]
  type = "service"
  
  group "webserver" {
  
    task "webserver" {
      driver = "docker"
      config {
        image = "nginx"
		    force_pull = true
		    port_map = {
		    webserver_web = 80
		} 
		logging {
		  type = "journald"
		  config {
		    tag = "WEBSERVER"
		 }
		}	
      }
	  
	  service {
	    name = "webserver"
	    port = "webserver_web"
	  } 
      resources {
        network {
          port "webserver_web" {
            static = "8000"
          }
        }
      }
    }
  }
}
END
