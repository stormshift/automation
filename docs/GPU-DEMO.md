![logo](StormShift.png)

# StormShift GPU Demo
Showcase the availability and performance of GPUs on OpenShift.

Check the availability of a GPU before you start.

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
TBD

## Show TF-Jobs using GPU
TBD





