import { useWriteContract } from 'wagmi'
import { DIAMOND_ADDRESS, VAULT_FACET_ABI } from '../../../shared/config/contracts'
import type { DepositArgs, WithdrawArgs } from '../types'

export function useDeposit() {
  const { writeContract, isPending, isSuccess, isError, error, data } = useWriteContract()

  const deposit = ({ assets, receiver }: DepositArgs) => {
    writeContract({
      address: DIAMOND_ADDRESS,
      abi: VAULT_FACET_ABI,
      functionName: 'deposit',
      args: [assets, receiver],
    })
  }

  return { deposit, isPending, isSuccess, isError, error, data }
}

export function useWithdraw() {
  const { writeContract, isPending, isSuccess, isError, error, data } = useWriteContract()

  const withdraw = ({assets, receiver, owner}: WithdrawArgs) => {
    writeContract({
      address: DIAMOND_ADDRESS,
      abi: VAULT_FACET_ABI,
      functionName: 'withdraw',
      args: [assets, receiver, owner],
    })
  }

  return { withdraw, isPending, isSuccess, isError, error, data }
}