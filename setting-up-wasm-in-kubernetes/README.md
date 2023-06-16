create a cluster using the base image as containerd-wasm runtime 

```
k3d cluster create wasm-cluster \
--image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.5.1 \
-p "8081:80@loadbalancer" --agents 2
```

```

```kubectl get nodes
NAME                        STATUS   ROLES                  AGE   VERSION
k3d-wasm-cluster-agent-1    Ready    <none>                 19m   v1.24.6+k3s1
k3d-wasm-cluster-agent-0    Ready    <none>                 19m   v1.24.6+k3s1
k3d-wasm-cluster-server-0   Ready    control-plane,master   19m   v1.24.6+k3s1
 ```

```
[holiodin@fedora wasm-wave]$ docker exec -it k3d-wasm-cluster-agent-0 ash
/ # ls /bin | grep containerd-
containerd-shim-runc-v2
containerd-shim-slight-v1
containerd-shim-spin-v1
/ # ps
PID   USER     COMMAND
    1 0        /sbin/docker-init -- /bin/k3d-entrypoint.sh agent
    6 0        {k3d-entrypoint.} /bin/sh /bin/k3d-entrypoint.sh agent
   22 0        /bin/k3s agent
   94 0        containerd -c /var/lib/rancher/k3s/agent/etc/containerd/config.toml -a /run/k3s/containerd/containerd.sock --state /run/k3s/containerd --root /var/lib/rancher/k3s/agent/containerd
  629 0        /bin/containerd-shim-runc-v2 -namespace k8s.io -id 3df37e337f9d3ec68df49c5d93abf1297a2423609abf30f10768e70ecc10f286 -address /run/k3s/containerd/containerd.sock
  650 65535    /pause
 1071 0        ash
 1498 0        local-path-provisioner start --config /etc/config/config.json
 1554 0        sleep 3
 1555 0        ps
/ # cat /var/lib/rancher/k3s/agent/etc/containerd/config.toml
[plugins.opt]
  path = "/var/lib/rancher/k3s/agent/containerd"
[plugins.cri]
  stream_server_address = "127.0.0.1"
  stream_server_port = "10010"
  enable_selinux = false
  sandbox_image = "rancher/mirrored-pause:3.6"

[plugins.cri.containerd]
  snapshotter = "overlayfs"
  disable_snapshot_annotations = true


[plugins.cri.cni]
  bin_dir = "/bin"
  conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d"

[plugins.cri.containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"







[plugins.cri.containerd.runtimes.spin]
  runtime_type = "io.containerd.spin.v1"

[plugins.cri.containerd.runtimes.slight]
  runtime_type = "io.containerd.slight.v1"
/ # exit
```


```
[holiodin@fedora wasm-wave]$ kubectl get nodes --show-labels
NAME                        STATUS   ROLES                  AGE     VERSION        LABELS
k3d-wasm-cluster-agent-0    Ready    <none>                 6m11s   v1.24.6+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,egress.k3s.io/cluster=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3d-wasm-cluster-agent-0,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
k3d-wasm-cluster-agent-1    Ready    <none>                 6m11s   v1.24.6+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,egress.k3s.io/cluster=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3d-wasm-cluster-agent-1,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s
k3d-wasm-cluster-server-0   Ready    control-plane,master   6m17s   v1.24.6+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,egress.k3s.io/cluster=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3d-wasm-cluster-server-0,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=true,node-role.kubernetes.io/master=true,node.kubernetes.io/instance-type=k3s
```


```
[holiodin@fedora wasm-wave]$ kubectl label nodes k3d-wasm-cluster-agent-0 spin=yes
node/k3d-wasm-cluster-agent-0 labeled
[holiodin@fedora wasm-wave]$ kubectl get nodes --show-labels | grep spin
k3d-wasm-cluster-agent-0    Ready    <none>                 9m39s   v1.24.6+k3s1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=k3s,beta.kubernetes.io/os=linux,egress.k3s.io/cluster=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k3d-wasm-cluster-agent-0,kubernetes.io/os=linux,node.kubernetes.io/instance-type=k3s,spin=yes
```


```
[holiodin@fedora wasm-wave]$ kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: spin-test
handler: spin
scheduling:
  nodeSelector:
    spin: "yes"
EOF
runtimeclass.node.k8s.io/spin-test created
```


```
[holiodin@fedora wasm-wave]$ kubectl apply \
-f https://raw.githubusercontent.com/nigelpoulton/spin1/main/app.yml
deployment.apps/wasm-spin created
service/wasm-spin created
middleware.traefik.containo.us/strip-prefix created
ingress.networking.k8s.io/wasm-ingress created
```


```
[holiodin@fedora wasm-wave]$ kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
wasm-spin-5bd4bd7b9-ss7vz   1/1     Running   0          63s
[holiodin@fedora wasm-wave]$ curl -v http://127.0.0.1:8081/spin/hello
*   Trying 127.0.0.1:8081...
* Connected to 127.0.0.1 (127.0.0.1) port 8081 (#0)
> GET /spin/hello HTTP/1.1
> Host: 127.0.0.1:8081
> User-Agent: curl/8.0.1
> Accept: */*
> 
< HTTP/1.1 200 OK
< Content-Length: 22
< Date: Fri, 16 Jun 2023 04:53:08 GMT
< Content-Type: text/plain; charset=utf-8
< 
* Connection #0 to host 127.0.0.1 left intact
Hello world from Spin![holiodin@fedora wasm-wave]$ 



```