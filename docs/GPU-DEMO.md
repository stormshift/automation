![logo](StormShift.png)

# StormShift GPU Demo
Showcase the availability and performance of GPUs on OpenShift.

## Check the availability of a GPU before you start

### Quick view at the operator

Check pods in ```gpu-operator-resources``` namespace:

```
oc get pods -n gpu-operator-resources

## Expected output:
NAME                                       READY   STATUS      RESTARTS   AGE
gpu-operator-59847dc475-8tck7              1/1     Running     0          6d3h
nfd-master-gmwlz                           1/1     Running     0          8d
nfd-master-qcj9k                           1/1     Running     0          8d
nfd-master-tcl8r                           1/1     Running     0          8d
nfd-operator-9946ddc57-cx4nj               1/1     Running     0          8d
nfd-worker-cmlsb                           1/1     Running     5          8d
nvidia-container-toolkit-daemonset-8qc2l   1/1     Running     0          8d
nvidia-dcgm-exporter-bskqk                 1/1     Running     3          8d
nvidia-device-plugin-daemonset-ng2zg       1/1     Running     0          6d2h
nvidia-device-plugin-validation            0/1     Completed   0          6d2h
nvidia-driver-daemonset-c8h5w              1/1     Running     0          8d
nvidia-driver-validation                   0/1     Completed   0          6d2h
```

Have a look at the driver and plugin validation:


```
oc logs nvidia-driver-validation -n gpu-operator-resources

## Expected output:
> Using CUDA Device [0]: Tesla K20Xm
> GPU Device has SM 3.5 compute capability
[Vector addition of 50000 elements]
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done
```
```
oc logs nvidia-device-plugin-validation -n gpu-operator-resources

## Expected output:
> Using CUDA Device [0]: Tesla K20Xm
> GPU Device has SM 3.5 compute capability
[Vector addition of 50000 elements]
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done
```

### View GPU utilization

To view GPU utilization, run nvidia-smi from a pod in the GPU operator daemonset.
```
oc get pods -l app=nvidia-driver-daemonset -n gpu-operator-resources
NAME                            READY   STATUS    RESTARTS   AGE
nvidia-driver-daemonset-c8h5w   1/1     Running   0          8d

oc exec -it nvidia-driver-daemonset-c8h5w nvidia-smi
```

Expected results with a idle GPU:
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.64.00    Driver Version: 440.64.00    CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla K20Xm         On   | 00000000:03:00.0 Off |                    0 |
| N/A   46C    P8    18W / 235W |     11MiB /  5700MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+

```

Expected results with a busy GPU:
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.64.00    Driver Version: 440.64.00    CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla K20Xm         On   | 00000000:03:00.0 Off |                    0 |
| N/A   54C    P0    97W / 235W |     78MiB /  5700MiB |     91%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0   2097235      C   .../64bit/22-0.0.11/Core_22.fah/FahCore_22    66MiB |
+-----------------------------------------------------------------------------+
```

### View the nodes

```
oc describe nodes | grep "nvidia.com/gpu" -B10

  Hostname:    storm5.coe.muc.redhat.com
Capacity:
  cpu:                              44
  devices.kubevirt.io/kvm:          110
  devices.kubevirt.io/tun:          110
  devices.kubevirt.io/vhost-net:    110
  ephemeral-storage:                125277164Ki
  hugepages-1Gi:                    0
  hugepages-2Mi:                    0
  memory:                           792513288Ki
  nvidia.com/gpu:                   1
--
  pods:                             250
Allocatable:
  cpu:                              43500m
  devices.kubevirt.io/kvm:          110
  devices.kubevirt.io/tun:          110
  devices.kubevirt.io/vhost-net:    110
  ephemeral-storage:                114381692328
  hugepages-1Gi:                    0
  hugepages-2Mi:                    0
  memory:                           791362312Ki
  nvidia.com/gpu:                   1
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                         Requests          Limits
  --------                         --------          ------
  cpu                              2243m (5%)        99700m (229%)
  memory                           16119784001 (1%)  5396126208 (0%)
  ephemeral-storage                0 (0%)            0 (0%)
  devices.kubevirt.io/kvm          2                 2
  devices.kubevirt.io/tun          1                 1
  devices.kubevirt.io/vhost-net    1                 1
  nvidia.com/gpu                   1                 1
                         Busy GPU ^^^               ^^^
```
```
oc describe nodes | grep "nvidia.com/gpu" -B10

Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                         Requests          Limits
  --------                         --------          ------
  cpu                              2143m (4%)        700m (1%)
  memory                           11824816705 (1%)  1101158912 (0%)
  ephemeral-storage                0 (0%)            0 (0%)
  devices.kubevirt.io/kvm          2                 2
  devices.kubevirt.io/tun          1                 1
  devices.kubevirt.io/vhost-net    1                 1
  nvidia.com/gpu                   0                 0
                         Free GPU ^^^               ^^^
```

## Brief performance tests of CPUs vs GPU with TensorFlow
Note, the demo flow contains a few workarounds due to few issues with Open Data Hub 0.7.0. 

### Install Open Data Hub 

The Open Data Hub Operator 0.7.0 is usually already installed cluster wide on OCP4 and OCP5. You just need to create your own project, wait until the Open Data Hub operator is visible and create an instance.

#### Create an Open Data Hub instance

In your newly created project, navigate to Installed Operators and open the Open Data Hub Operator:

![OpenDataHubOperator](images/OpenDataHubOperator.png)

Click on create instance in the Open Data Hub tile.
The default KfDef will show up:

![DefaultKfDef](images/DefaultKfDef.png)

Delete the whole content and insert the content of the custom Kfdef as follows:

[Open Data Hub Kfdef with GPU specific changes for ODH 0.7.0 for OCP 4.5](files/odh-kfdef-gpu-070.yaml)

Click ```[Create]```

This KfDef triggers the builds of the GPU notebooks due to the ```- cuda``` parameter.

```
...
        parameters:
          - name: cuda_version
            value: "10.2"
        overlays:
          - cuda
...
```
Navigate in the OpenShift Admin Console to ```Build -> Builds``` and watch the notebook builds until the finish. (this will take some time)

### Lauch Jupyter Hub

Launch Jupyter Hub by clicking on the location of Jupyterhub route:
![JupyterhubRoute](images/JupyterhubRoute.png)

Sign in with OpenShift credentials.

Enter the needed data in the Jupyter Spawner Options:

- Select the tesorflow-gpu notebook
- Set  GPU = 1
- Add a variable LD_LIBRARY_PATH = $LD_LIBRARY_PATH:/opt/app-root/lib64

![JupyterhubSpawner](images/JupyterhubSpawner.png)

Start the Jupyter Hub, presse ```[Spawn]```! (it will take some time)

If no GPU is free, you will see ``` [Warning] 0/6 nodes are available: 6 Insufficient nvidia.com/gpu.  ```

### Upload demo notebook

Download the demo notebook on your laptop/desktop:
[tensorflow-with-gpu.ipynb](files/tensorflow-with-gpu.ipynb)

```
curl -O https://raw.githubusercontent.com/DanielFroehlich/stormshift/master/docs/files/tensorflow-with-gpu.ipynb
```


In the Jupyter Hub select ```[Upload]```, and upload the previously downloaded notebook ```tensorflow-with-gpu.ipynb```:

![JupyterhubUpload](images/JupyterhubUpload.png)

Open the notebook and follow the instructions.

### Showcase the performance of CPUs vs GPU with TensorFlow

The notebook should have enough information so that you can follow it and demo. 
Anyhoe, here a few tips:
- Run cells step by step with ```shift-enter```
- As long as the cell number show a [*], the cell is still running. 
- Clear all cells with ```Cells -> Current Outputs -> Clear``` or ```Kernel -> Restart and Clear Output```
- The steps/cells in **Prepare the notebook** are ugly. Please run them before you show the demo.
- You might have to run the cell below ```Plot results``` twice to see the bar chart.



## GPU based model training
For showing an end to end model training you can the Keras example [OCR model for reading Captchas](https://keras.io/examples/vision/captcha_ocr/)

- Upload the notebook [captcha_ocr.ipynb](files/captcha_ocr.ipynb)
- Ensure you have Tensorflow 2.3.0  installed: ```!pip install tensorflow-gpu==2.3.0```
- Step through notebook. The explanation are pretty good.
- During the training phase show how fast the model is learning:

```
...
Epoch 5/100
59/59 [==============================] - 7s 120ms/step - loss: 16.3321 - val_loss: 16.4150
Epoch 6/100
59/59 [==============================] - 7s 124ms/step - loss: 16.3303 - val_loss: 16.4162
Epoch 7/100
59/59 [==============================] - 8s 130ms/step - loss: 16.3219 - val_loss: 16.4019
...
Epoch 13/100
59/59 [==============================] - 9s 157ms/step - loss: 11.0869 - val_loss: 7.7286
Epoch 14/100
59/59 [==============================] - 9s 155ms/step - loss: 5.9264 - val_loss: 3.6818
Epoch 15/100
59/59 [==============================] - 8s 129ms/step - loss: 2.8195 - val_loss: 1.5599
Epoch 16/100
59/59 [==============================] - 9s 153ms/step - loss: 1.4770 - val_loss: 0.7692
Epoch 17/100
59/59 [==============================] - 8s 138ms/step - loss: 0.8761 - val_loss: 0.3705
...
```


## Show Tensorflow Jobs using a GPU

Clone the tensorflow-playground repo:
```
git clone https://github.com/stefan-bergstein/tensorflow-playground.git
```

Follow step in [Tensorflow GPU Training Jobs with MNIST](https://github.com/stefan-bergstein/tensorflow-playground/blob/master/tf-gpu-mnist-job/README.md) README.

Note,
- Build the image before run the demo
- The demo uses plan K8S jon and not yet Kubeflow TF-Jobs





