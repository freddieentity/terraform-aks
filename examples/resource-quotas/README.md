Resources must specify resources request and limits before applying
## Resources Request & Limits
Kubernetes uses the requests and limits to control resources such as CPU and memory.
Requests guarantees what the container will get immediately. For example, If a
container requests a resource, Kubernetes will only schedule it on a node that can give it
that resource.
Limits is a resource threshold which container cannot exceed. The container is only
allowed to go up to the limit, and then it is restricted.
In case container reaches its CPU limit then it will keep running but the operating system will
throttle it and keep de-scheduling from using the CPU because CPU is a compressible
resource. Memory, on the other hand, is a non compressible resource. Once container
reaches the memory limit, it will be terminated with OOM (Out of Memory). If container keeps
getting OOM killed, Kubernetes will report that it is in a crash loop.