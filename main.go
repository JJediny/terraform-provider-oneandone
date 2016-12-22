package main

import (
	"github.com/1and1/terraform-provider-oneandone/provider"
	"github.com/hashicorp/terraform/plugin"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: oneandone.Provider,
	})
}
