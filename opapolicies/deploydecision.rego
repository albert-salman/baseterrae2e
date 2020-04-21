package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

# acceptable score for automated authorization
blast_radius = __opariskscore__
dweight = __opadeleteweight__
cweight = __opacreateweight__
mweight = __opamodifyweight__

# weights assigned for each operation on each resource-type
weights = {
    "azurerm_resource_group": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_virtual_network": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_subnet": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_public_ip": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_bastion_host": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_subnet": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_public_ip": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_firewall": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_route_table": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_windows_virtual_machine": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_subnet_route_table_association": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_firewall_application_rule_collection": {"delete": dweight, "create": cweight, "modify": mweight},
    "azurerm_network_interface": {"delete": dweight, "create": cweight, "modify": mweight}
}

# Consider exactly these resource types in calculations
resource_types = {"azurerm_resource_group", "azurerm_virtual_network", "azurerm_firewall","azurerm_network_interface",
                  "azurerm_windows_virtual_machine","azurerm_subnet_route_table_association",
                  "azurerm_subnet","azurerm_public_ip","azurerm_bastion_host","azurerm_route_table",
                  "azurerm_firewall_application_rule_collection"
                  }
#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
default authz = false
authz {
    score < blast_radius
    not touches_iam
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score = s {
    all := [ x |
            some resource_type
            crud := weights[resource_type];
            del := crud["delete"] * num_deletes[resource_type];
            new := crud["create"] * num_creates[resource_type];
            mod := crud["modify"] * num_modifies[resource_type];
            x := del + new + mod
    ]
    s := sum(all)
}

# Whether there is any change to IAM
touches_iam {
    all := resources["aws_iam"]
    count(all) > 0
}

####################
# Terraform Library
####################

# list of all resources of a given type
resources[resource_type] = all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
    ]
}

# number of creations of resources of a given type
num_creates[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    creates := [res |  res:= all[_]; res.change.actions[_] == "create"]
    num := count(creates)
}


# number of deletions of resources of a given type
num_deletes[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    deletions := [res |  res:= all[_]; res.change.actions[_] == "delete"]
    num := count(deletions)
}

# number of modifications to resources of a given type
num_modifies[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [res |  res:= all[_]; res.change.actions[_] == "update"]
    num := count(modifies)
}