use aiken/list
use aiken/transaction.{ScriptContext, Input, Output, Transaction, Spend,find_script_outputs}
use aiken/transaction/value.{Value, zero, merge}
use aiken/transaction/credential.{from_verification_key}
use types.{PolicyId, PublicKeyHash, TokenName}
use aiken/bytearray


//get all the value of the inputs as an int 
pub fn inputs_int(inputs: List<Input>) -> Int {
  //v is the accumulator for the foldl function 
  let f = fn(i: Input, v: Int) -> Int {
    value.lovelace_of(i.output.value) + v 
  }
  list.foldl(inputs,0,f)  
}

//take a list of inputs and return the value
//get all inputs value, identical to Plutus valueSpent function
pub fn inputs_value(inputs: List<Input>) -> Value {
  let inputs_ = list.map(inputs, fn(n) {n.output.value})
  list.foldr(inputs_, zero(), fn(in1,in2) {merge(in1, in2)})
}


// Get value paid to a public key address by a pending transaction
pub fn value_paid_to(outputs: List<Output>, receiver: PublicKeyHash) -> Value {
  let addr = from_verification_key(receiver)
  expect [match] = list.filter(outputs, fn(output) {output.address == addr})
  match.value 
}

// Get input from the script.
pub fn find_own_input(ctx: ScriptContext) -> Input {
  let ScriptContext {transaction, purpose } = ctx 
  let Transaction {inputs, ..} = transaction

  //expect that it is a spend purpose with an out_ref
  expect Spend(out_ref) = purpose 

  //expect and input from the out_ref.
  expect Some(input) = inputs
                        |> transaction.find_input(out_ref) 

  input  

}

// Get outputs to the script.
pub fn find_own_outputs(ctx: ScriptContext) -> List<Output> {
   let ScriptContext {transaction, purpose } = ctx 
  let Transaction {outputs, ..} = transaction

  //expect that it is a spend purpose with an out_ref
  expect Spend(out_ref) = purpose 

  //find the output based on the hash of the transaciton id hash
  let own_outputs = outputs |> find_script_outputs(out_ref.transaction_id.hash)
  own_outputs
}

// Get all outputs value.
pub fn outputs_value(outputs: List<Output>) -> Value {
  let outputs_ = list.map(outputs, fn (o) {o.value})
  list.foldr(outputs_, zero(), fn (in1,in2) {merge(in1,in2)})
}

// Compare the token name without the label. 
pub fn comparing(a: ByteArray, b: ByteArray) -> Bool {
  let sliced_a = bytearray.drop(a, n: 3)
  bytearray.compare(sliced_a, b) == Equal
}


