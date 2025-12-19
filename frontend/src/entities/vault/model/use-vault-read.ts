
import { useReadContract } from 'wagmi'
import { DIAMOND_ADDRESS, VAULT_FACET_ABI } from '../../../shared/config/contracts'
import { type Address } from 'viem'
import type { Amount } from '../types'
export function useTotalAssets() {
  return useReadContract({
    address: DIAMOND_ADDRESS,     
    abi: VAULT_FACET_ABI,       
    functionName: "totalAssets" 
  })
}


export function useBalanceOf(account: Address | undefined) {
    return useReadContract({
    address: DIAMOND_ADDRESS,     
    abi: VAULT_FACET_ABI,       
    functionName: "balanceOf",
    args: [account!], 
    query: {
      enabled: !!account  
    }
  })
}

export function useAsset() {
    return useReadContract({
        address: DIAMOND_ADDRESS,
        abi: VAULT_FACET_ABI,
        functionName: "asset"
    })
    
}

export function useConvertToShares(assets: Amount) {
    return useReadContract({
        address: DIAMOND_ADDRESS,
        abi: VAULT_FACET_ABI,
        functionName: "convertToShares",
        args: [assets!],
        query: {
            enabled: !!assets 
        }
  })
}

export function useConvertToAssets(shares: Amount) {
    return useReadContract({
        address: DIAMOND_ADDRESS,
        abi: VAULT_FACET_ABI,
        functionName: "convertToAssets",
        args: [shares!],
         query: {
            enabled: !!shares 
        }
  })
}
