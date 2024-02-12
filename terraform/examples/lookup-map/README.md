# lookup-map example

UPDATE: doesn't look like this functionality is supported :'()

## usage

```bash
# init
cd terraform/examples/lookup-map
terraform init

# show plan
terraform plan

# enter console
terraform console

# output locals to view data structures

# can you now use?:
# var region = "primary" or "secondary"
# var region = "secondary"
# local.${var.region}.location
# local.${var.region}.location_abbr

local.${local.region}.location
var.locals_map_path

# lookup(map, key, default)
# this works
lookup(local.primary, "location", "default")
# this does NOT work
lookup(local.${local.region}, "location", "default")
# this does NOT work
lookup(${var.locals_map_path}, "location", "default")

# show plan
terraform plan
```

if true ? this : true ? this : that
