## Inception of Things (IoT)

Inception of Things is a project focused on system administration, using Vagrant and Kubernetes technologies like K3s and K3d. The project is designed to introduce you to virtualization, container orchestration, and continuous integration, specifically with Kubernetes in virtualized environments.

For more information, please refer to the subject in the Git repository.

---

### Services

The project involves the following tools and technologies:

1. **Vagrant**: A tool for building and managing virtualized development environments. You will use Vagrant to create virtual machines and simulate infrastructure environments.
  
2. **K3s**: A lightweight version of Kubernetes that will be installed on the virtual machines. It allows you to simulate Kubernetes environments with minimal resource consumption.

3. **K3d**: A tool for running K3s clusters in Docker containers, simplifying the setup and management of Kubernetes clusters.

4. **Argo CD**: A Continuous Delivery tool for Kubernetes, used to manage applications and deployments from a Git repository.

---

### Usage

Follow the steps below to set up and manage your virtual machines and Kubernetes clusters.

#### Part 1/2: K3s and Vagrant

1. **How to launch P1 and P2**:
    ```bash
    vagrant up
    ```

#### Part 3: K3d and Argo CD

1. **How to launch P3**:
    ```bash
    ./start.sh
    ```
