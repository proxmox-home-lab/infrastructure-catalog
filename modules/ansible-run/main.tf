locals {
  # Build inventory string: one host per line
  inventory_content = join("\n", var.inventory_hosts)

  # Build --extra-vars JSON string if any extra vars provided
  extra_vars_arg = length(var.extra_vars) > 0 ? "--extra-vars '${jsonencode(var.extra_vars)}'" : ""
}

resource "null_resource" "playbook" {
  triggers = merge(var.triggers, {
    playbook_path   = var.playbook_path
    inventory_hosts = join(",", sort(var.inventory_hosts))
  })

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      # Write inventory to a temp file
      inventory_file=$(mktemp)
      trap "rm -f $inventory_file" EXIT
      printf '%s\n' "${local.inventory_content}" > "$inventory_file"

      ansible-playbook \
        -i "$inventory_file" \
        --private-key "${var.ssh_private_key_path}" \
        --user "${var.remote_user}" \
        ${local.extra_vars_arg} \
        "${var.playbook_path}"
    EOT
  }
}
