
import { useReadContract } from 'wagmi'
import { DIAMOND_ADDRESS, ACCESS_FACET_ABI } from '../../../shared/config/contracts'
import { type Address } from 'viem'

export function useIsWhitelisted(account: Address | undefined) {
  return useReadContract({
    address: DIAMOND_ADDRESS,     
    abi: ACCESS_FACET_ABI,       
    functionName: "isWhitelisted", 
    args: [account!], 
    query: {
      enabled: !!account  
    }
  })
}


export function useGetAdmin() {
    return useReadContract({
    address: DIAMOND_ADDRESS,     
    abi: ACCESS_FACET_ABI,       
    functionName: "getAdmin",
  })
}

export function useGetWhitelistedAddresses() {
    return useReadContract({
    address: DIAMOND_ADDRESS,     
    abi: ACCESS_FACET_ABI,       
    functionName: "getWhitelistedAddresses",
  })
}
