//========================================================================================================================================================================================================200
//	findK function
//========================================================================================================================================================================================================200

__global__ void 
findK(	long height,
		knode *knodesD,
		long knodes_elem,
		record *recordsD,

		long *currKnodeD,
		long *offsetD,
		int *keysD, 
		record *ansD)
{

	// private thread IDs
	int thid = threadIdx.x;
	int bid = blockIdx.x;

	// currKnodeD[bid]/offsetD[bid] are read/written identically by every
	// thread in the block, every iteration -- hoist into shared memory for
	// the loop's duration instead of re-reading/writing global memory each
	// time, writing back once after the loop. Same multi-writer semantics
	// as the original (whichever thread's range condition matches writes
	// s_offset, same as it wrote offsetD[bid] before) -- purely a memory
	// hierarchy change, not a behavior change. (GPUWarpBalanceOptimizer /
	// GPUCodeReorderOptimizer: reduces the memory latency each barrier is
	// waiting on, via a different mechanism than the already-REVERTED
	// per-thread-register hoist attempt -- shared memory is visible to all
	// threads after a sync, avoiding that attempt's correctness pitfall.)
	__shared__ long s_currKnode;
	__shared__ long s_offset;
	if (thid == 0) {
		s_currKnode = currKnodeD[bid];
		s_offset = offsetD[bid];
	}
	__syncthreads();

	// processtree levels -- GPULoopUnrollOptimizer's top untried finding
	// (impact 0.038, ratio 17.6% at this loop header, GINS:LAT_DEP): the
	// s_currKnode update at the end of each iteration feeds directly into
	// next iteration's knodesD[s_currKnode] read, a sequential dependency
	// chain across tree levels. height is a runtime kernel parameter,
	// uniform across every thread in the block, so unrolling doesn't risk
	// divergence at the __syncthreads() calls inside the loop body.
	int i;
	#pragma unroll
	for(i = 0; i < height; i++){

		// if value is between the two keys
		if((knodesD[s_currKnode].keys[thid]) <= keysD[bid] && (knodesD[s_currKnode].keys[thid+1] > keysD[bid])){
			// this conditional statement is inserted to avoid crush due to but in original code
			// "offset[bid]" calculated below that addresses knodes[] in the next iteration goes outside of its bounds cause segmentation fault
			// more specifically, values saved into knodes->indices in the main function are out of bounds of knodes that they address
			if(knodesD[s_offset].indices[thid] < knodes_elem){
				s_offset = knodesD[s_offset].indices[thid];
			}
		}
		__syncthreads();

		// set for next tree level
		if(thid==0){
			s_currKnode = s_offset;
		}
		__syncthreads();

	}

	if (thid == 0) {
		currKnodeD[bid] = s_currKnode;
		offsetD[bid] = s_offset;
	}

	//At this point, we have a candidate leaf node which may contain
	//the target record.  Check each key to hopefully find the record
	if(knodesD[s_currKnode].keys[thid] == keysD[bid]){
		ansD[bid].value = recordsD[knodesD[s_currKnode].indices[thid]].value;
	}

}

//========================================================================================================================================================================================================200
//	End
//========================================================================================================================================================================================================200
