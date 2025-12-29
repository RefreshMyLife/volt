import { useWriteContract } from 'wagmi'
import { DIAMOND_ADDRESS, ACCESS_FACET_ABI } from '../../../shared/config/contracts'
import { type Address } from 'viem'
export function useAddToWhitelist() { 
  const { writeContract, isPending, isSuccess, isError, error, data } = useWriteContract()

  const addToWhitelist = (account: Address) => {
    writeContract({
      address: DIAMOND_ADDRESS,
      abi: ACCESS_FACET_ABI,
      functionName: 'addToWhitelist',
      args: [account],
    })
  }

  return { addToWhitelist, isPending, isSuccess, isError, error, data }
}

export function useRemoveFromWhitelist() {
  const { writeContract, isPending, isSuccess, isError, error, data } = useWriteContract()

  const removeFromWhitelist = (account: Address) => {
    writeContract({
      address: DIAMOND_ADDRESS,
      abi: ACCESS_FACET_ABI,
      functionName: 'removeFromWhitelist',
      args: [account],
    })
  }

  return { removeFromWhitelist, isPending, isSuccess, isError, error, data }
}