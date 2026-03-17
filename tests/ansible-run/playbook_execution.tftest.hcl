mock_provider "null" {
  mock_resource "null_resource" {
    defaults = {
      id = "playbook-run-1"
    }
  }
}

variables {
  playbook_path        = "ansible/haproxy/playbook.yml"
  ssh_private_key_path = "/tmp/test-key"
}

run "single_host_standalone" {
  command = plan

  variables {
    inventory_hosts = ["10.10.0.10"]
  }

  assert {
    condition     = length(null_resource.playbook) == 1
    error_message = "Expected 1 null_resource for single host"
  }
}

run "cluster_multiple_hosts" {
  command = plan

  variables {
    inventory_hosts = ["10.10.0.10", "10.10.0.11", "10.10.0.12"]
  }

  assert {
    condition     = length(null_resource.playbook) == 1
    error_message = "Expected 1 null_resource regardless of host count (single playbook run)"
  }
}

run "extra_vars_accepted" {
  command = plan

  variables {
    inventory_hosts = ["10.10.0.10"]
    extra_vars = {
      stats_port   = "8404"
      backend_mode = "http"
    }
  }

  assert {
    condition     = length(null_resource.playbook) == 1
    error_message = "Expected playbook resource with extra_vars"
  }
}

run "triggers_force_rerun" {
  command = plan

  variables {
    inventory_hosts = ["10.10.0.10"]
    triggers = {
      haproxy_version = "2.8.0"
    }
  }

  assert {
    condition     = length(null_resource.playbook) == 1
    error_message = "Expected playbook resource with custom triggers"
  }
}
