# Inception-of-Things (IoT)

This project aims to deepen your knowledge by making you use `K3d` and `K3s` with
Vagrant.

You will learn how to set up a personal virtual machine with `Vagrant` and the
distribution of your choice. Then, you will learn how to use `K3s` and its `Ingress`.

Last but not least, you will discover `K3d` that will simplify your life.

## P1

In the p1, you will learn how to set up a personal virtual machine with `Vagrant` and the distribution of your choice. Then, you will learn how to use `K3s` in
server mode and agent mode.

```bash
## to launch the p1
vagrant up

## connect with ssh via the name of the VM
vagrant ssh $NAME
```

> For the SSH connection, use the private key in the .vagrant folder, located at:
> `.vagrant/machines/NAME_OF_THE_VM/virtualbox/private_key`

```bash
ssh -i .vagrant/machines/bapasquiS/virtualbox/private_key vagrant@192.168.56.110
ssh -i .vagrant/machines/bapasquiSW/virtualbox/private_key vagrant@192.168.56.111
```

1. **K3s**: Lightweight Kubernetes distribution.
2. **Vagrant**: Tool for building and managing virtual machine environments in a single workflow.

## P2

In this second part, you will learn how to use `k3s`, `Ingress`, and all terms related to Kubernetes.

```bash
## to launch the p2
vagrant up

## to get the ingress
kubectl get ingress -o wide
```

```bash
# Setup domain local name in /etc/hosts
# might need to use .local since .com already in use by a real domain
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```
1. **Pod**: Group of containers that run your application.
2. **Deployment**: Manages and automates the creation and management of Pods via a ReplicaSet.
3. **ReplicaSet**: Ensures the correct number of Pods are running.
4. **Service**: Connects the Pods to each other or to the outside world.
5. **Ingress** : Exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.

[The Webpage for the Deployment](https://github.com/paulbouwer/hello-kubernetes)

## P3

In this last part, you will learn how to use `K3d` and `ArgoCD` to deploy your application.

```bash
## to launch the p3
sudo bash scripts/start.sh

# get the name of the pod
kubectl get pods -n dev

#port-forward for curl
kubectl port-forward -n dev pod/<pod-name> 8888:8888
```

1. **ArgoCD**: Continuous Delivery tool for Kubernetes.
2. **v2** and **v1** are the two versions of the application.
3. **k3d** is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in Docker.
4. **K3s** is a lightweight Kubernetes distribution.

## Bonus

In the bonus part, you should setup a `Gitlab` instance and deploy the application with `ArgoCD`.

```bash
## to launch the bonus (and p3 argocd)
sudo bash bonus/scripts/start.sh

## to stop the bonus and delete
sudo bash bonus/scripts/delete.sh
```
The creation of the repository is done automatically by the script `bonus/scripts/start.sh`.
The repo will be name `test` and the user `root`.

To make `ArgoCD` use the repo on the `gitlab` use the following command:

```bash
# this will update the ip and push the p3 to the gitlab repo
sudo bash bonus/scripts/update_argoc.sh
```

## COMMANDS

- `vagrant up` : Launch the VMs in listed in the Vagrantfile
- `vagrant  destroy [-f]` : Delete all VMs listed in the Vagrantfile
- `vboxmanage list vms` : lists all VMs in virtualbox
- `vagrant provision` : Update the VM with the modifications in the Vagrantfile. 
- `kubectl get nodes` : List all the nodes.
- `vagrant reload` : Delete all machines and re-up them.
- `vagrant halt` : Shutdown the VM linked to the Vagrantfile.
