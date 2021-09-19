# Hashpipe

## High-Availability Shared Pipeline Engine

Hashpipe is a data processing pipeline engine that manages low-level resources to performantly handle data. Each Hashpipe pipeline is broken into a series of threads that share data with downstream threads via shared memory ring buffers whose access is controlled via semaphores. This package contains the base Hashpipe C-functionality [code here](https://github.com/david-macmahon/hashpipe) from the Julia programming language. A Hashpipe pipeline can either be composed in a single language (either Julia or C) or be a mix of both.

### Primary Topics to Understand

<ul>
<li>Status Buffers</li>
    <p>TODO:</p>
<li>Databuffers</li>
    <p>TODO:</p>
<li>Access Management (lock/unlock)</li>
    <p>TODO:</p>
</ul>

### Tips

- ipcs

## Example

A common use-case would be to have C-level Hashpipe threads preprocess network packets into a standard, astronomy-friendly data format. From there, Julia threads would execute the high-level data processing required. Here is what the Julia code for this scenario would look like assuming the C-level Hashpipe threads are already setup with the 

```
julia code here

```
