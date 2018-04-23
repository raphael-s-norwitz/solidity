contract SmartPonzi {
    
    bool success;
    uint fee;
    uint amount;
    uint public roi;
    uint public feeRate;
    uint public lastDepositTs;
    uint public minDiff;
    uint public numDeposits;
    address public manager;

    mapping (address => uint) public balances;
    mapping (address => uint) public deposits;
    mapping (address => uint) public cumulativeProfits;
    mapping (address => uint) public instantProfits;
    mapping (uint => address) public addresses;

    function SmartPonzi() {
        manager = msg.sender;
        numDeposits = 0;
        roi = 7;
        feeRate = 7;
        minDiff = 1;
    }

    function getBalance() constant returns (uint balance) {
        return balances[msg.sender];
    }
    
    function getProfit() constant returns (uint profit) {
        return instantProfits[msg.sender];
    }

    function getCumulativeProfit() constant returns (uint profit) {
        return cumulativeProfits[msg.sender];
    }

    function getDepositDelta() constant returns (uint depositDelta){
        return (block.timestamp - deposits[msg.sender]);

    }

    function deposit()  {
            ++numDeposits;
            lastDepositTs = block.timestamp;
            addresses[numDeposits] = msg.sender;
            balances[msg.sender] += msg.value;  
            reCalc();
    }


    function reCalc() {
            if ((((block.timestamp - deposits[msg.sender]) / 3600) / 24) >= minDiff){ 
                if (balances[msg.sender] > 0){
                    fee = (( (( (balances[msg.sender] + instantProfits[msg.sender] ) * roi ) / 100 ) * feeRate ) / 100 );
                    amount = ((( (balances[msg.sender] + instantProfits[msg.sender]) * roi ) / 100 ) - fee);
                    if (this.balance > 0) {
                        success = manager.send(fee);  
                    }                         
                    instantProfits[msg.sender] += amount;
                    cumulativeProfits[msg.sender] += amount;
                    deposits[msg.sender] =  block.timestamp;                
                }
            }
    }


    function withdraw() {
            if ((((block.timestamp - deposits[msg.sender]) / 3600) / 24) >= minDiff){ 
                if (this.balance > ( balances[msg.sender] + cumulativeProfits[msg.sender]  )) {
                    success = msg.sender.send(( balances[msg.sender] + cumulativeProfits[msg.sender] ));
                    if (success) {
                    deposits[msg.sender] = block.timestamp;
                    instantProfits[msg.sender] = 0;  
                    balances[msg.sender] = 0;
                    }
                }         
            }
    }


    function withdrawProfit() {
            if ((((block.timestamp - deposits[msg.sender]) / 3600) / 24) >= minDiff){       
                if (this.balance > instantProfits[msg.sender]) {    
                    success = msg.sender.send(( instantProfits[msg.sender] ));
                    if (success){
                        instantProfits[msg.sender] = 0;
                        reCalc();                       
                    }
                }        
            }
    }

}

 
 

