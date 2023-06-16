k3d cluster create wasm-cluster \
--image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.5.1 \
-p "8081:80@loadbalancer" --agents 2


kubectl get nodes


docker exec -it k3d-wasm-cluster-agent-0 ash

ls /bin | grep containerd-

kubectl label nodes k3d-wasm-cluster-agent-0 spin=yes


kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: spin-test
handler: spin
scheduling:
  nodeSelector:
    spin: "yes"
EOF


kubectl apply \
-f https://raw.githubusercontent.com/nigelpoulton/spin1/main/app.yml


kubectl get pods


curl -v http://127.0.0.1:8081/spin/hello
