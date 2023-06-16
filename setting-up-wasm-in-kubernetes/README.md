How Wasm Works on kubernetes ?


create a cluster using the base image as containerd-wasm runtime 

```
k3d cluster create wasm-cluster \
--image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.5.1 \
-p "8081:80@loadbalancer" --agents 2
```

```

```kubectl get nodes ```

