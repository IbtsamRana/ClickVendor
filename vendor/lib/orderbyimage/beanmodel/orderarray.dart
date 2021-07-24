class OrderArrayGrocery{

  int qty;
  int varient_id;


  OrderArrayGrocery(this.qty, this.varient_id);

  @override
  String toString() {
    return '{\"qty\": $qty, \"varient_id\": $varient_id}';
  }
}