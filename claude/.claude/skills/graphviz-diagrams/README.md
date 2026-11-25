# graphviz-diagrams

Creates Graphviz diagrams as a fully commented `.dot` file plus a rendered `.png`.

**Run it:** `/graphviz-diagrams`, or ask for a diagram, flowchart, architecture diagram or dependency graph.

**What it does:** writes the `.dot` with a header block and a comment on every setting, cluster, node and edge, renders it with `dot -Tpng`, checks the PNG, and reports both paths. Existing `.dot` files are edited and re-rendered, with their comments kept accurate. No SVG unless asked.

**Needs (install once):** Graphviz, with `brew install graphviz`. Check with `dot -V`, which should print the Graphviz version.

**Writes:** the `.dot` and `.png` files only, beside the document or where you say. Nothing on Drive or Jira.
