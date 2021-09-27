# Hashpipe

## High-Availability Shared Pipeline Engine

Hashpipe is a data processing pipeline engine that manages low-level resources to performantly handle data. Each Hashpipe pipeline is broken into a series of threads that share data with downstream threads via shared memory ring buffers (databuffers) whose access is controlled via semaphores. This package contains the base Hashpipe C-functionality ([code here](https://github.com/david-macmahon/hashpipe)) from the Julia programming language. A Hashpipe pipeline can either be composed in a single language (either Julia or C) or be a mix of both.


### Primary Topics to Understand

<ul>
<li>Status Buffers</li>
    <p>Metadata about Hashpipe pipelines are stored in so-called status buffers. These are shared memory regions containing FITS-like keyword=value pairs of information (e.g. telescope name, databuf status, etc). Keys can be added to the status buffer in the same way that editing values of existing keys is done: lock the status buffer (to prevent multiple simultaneous edits), update/add the key=value pairs, and unlock the status buffer.</p>
    
<li>Databuffers</li>
    <p>The main data that you process and are trying to efficiently manage are stored in data buffers. These are also shared memory regions that Hashpipe threads store and access data to/from. Databuffers are designed to be so-called ring buffers where once operation ends on the last unit of data in the databuffer, the next data to be operated on is the first unit of the databuffer. In this way, the beginning and end of the databuffer are 'connected' and form a ring. The atomic units of data are called blocks, and you as the user can determine how many and how large these blocks are.</p>

<li>Access Management (lock/unlock)</li>
    <p>Since multiple threads/processes share the same data, there needs to be some access control mechanism. Hashpipe uses semaphores to do this, but there is a high-level user interface that abstracts the nitty-gritty details into simple lock/unlock functions for status buffers and wait free/filled functions for databuffers.</p>
    <p>The code below shows an example of what this process would look like for a status buffer. The three updates to the status buffer are all 'wrapped' in a safe function??? that handles the locking and unlocking for you.</p>
    
    Hashpipe.status_buf_lock_unlock(Ref(thread.status)) do
        Hashpipe.update_status(thread.status, "SRHSTAT", "Waiting");
        Hashpipe.update_status(thread.status, "SRHBLKIN", thread.input_block_id);
        Hashpipe.update_status(thread.status, "SRHBKOUT", thread.output_block_id);
    end

<p>Below is an example of databuffer access management. Note that this is a bit different than status buffers because  </p>

    # Busy loop to wait for filled databuffer block
    while (rv=Hashpipe.databuf_wait_filled(thread.input_db_p, thread.input_block_id)) != Hashpipe.HASHPIPE_OK
        if rv==HASHPIPE_TIMEOUT
            @warn "Search thread ($(thread.searchAlgoName)) timeout waiting for filled block"
        else
            @error "Search thread ($(thread.searchAlgoName)) error waiting for filled databuf - Error: $rv"
        end
    end
    # Process data here...
    # Set databuffer block to free
	Hashpipe.databuf_set_free(thread.output_db_p, thread.input_block_id)

</ul>

### Tips

- Since Hashpipe data is managed via semaphores, the Linux command-line tool ipcs (inter-process communication status) can be very helpful at times.
- Similarly, ipcrm can be used to remove those shown IPC resources.

## Example

A common use-case would be to have C-level Hashpipe threads preprocess network packets into a standard, astronomy-friendly data format. From there, Julia threads would execute the high-level data processing required. Here is what the Julia code for this scenario would look like assuming the C-level Hashpipe threads are already setup with the 

```
julia code here

```
