check_linux Cookbook
============================
TODO: Cookbook to deploy check_linux server

Requirements
------------
Chef Cookbook to collect custom Metrics for AWS Cloudwatch
This cookbook collects:
MemoryUtilization
SystemUpdatesCritical
SystemUpdatesImportant
AVDatVersion



Usage
-----
#### check_linux::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `check_linux` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[check_linux]"
  ]
}
```

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: TODO: List authors
