using Hashpipe
using Test

@testset "Hashpipe.jl" begin
    @testset "Status" begin
        instance_id = 98
        @test status_exists(instance_id) == 0
        status = status_t(0,0,0,0)
        @test status_attach(instance_id, Ref(status)) == 0

        @test status_exists(instance_id) == 1
        @test status_unlock(Ref(status)) == 0
        update_status(status, "JLTEST", "RUNNING")
        status_buf_lock_unlock(Ref(status)) do
            update_status(status, "JLTEST", "COMPLETE")
        end
        @test status_lock(Ref(status)) == 0

        # Detach from and delete shared memory segment
        status_detach(Ref(status))
        ipcrm_cmd = `ipcrm -m $(status.shmid)`
        run(ipcrm_cmd)
        @test status_exists(instance_id) == 0
    end

    @testset "Databuf" begin
        # TODO: Test creation, data retrieval, updating, locking, unlocking
        # TODO: Test hput/get functions
        #db = Hashpipe.databuf_create()
    end

    @testset "Thread" begin
        # Test registration and finding
    end
end
