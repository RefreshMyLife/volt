
import { type Address } from 'viem'
export type Amount = bigint | undefined;

export type DepositArgs = {
  assets: bigint;
  receiver: Address;
};

export type WithdrawArgs = {
  assets: bigint;
  receiver: Address;
  owner: Address;
}