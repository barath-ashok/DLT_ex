//This file serves as a guided exercise for learning smart contract programming using the solidity language
//It is best worked with in an interactive manner (via a code editor) where the user opens on a copy of this file and
//edits the file by reading the comments, such as this one. You will mainly find two kinds of comments - exercise and indicator.
//Each exercise comment is numbered starting from 1,2,3,...,etc,. and
//associated with each exercise comment is a fixed-format indicator comment "/*[X]*/" (by itself or in a line of code) where you are 
//expected to supply a code fragment or keyword - thereby "solving" the associated exercise. 
//This file has a total of N=17 comments.
/*------------------------------------------------------------------------------------*/
/*---------------------We begin---------------------*/
//1. Smart Contract Convention: Declare the license of contract source code as a code comment.
//btw, why do smart "contracts" need a license anyway?

/*[1]*/

//2. Declare a pragma directive to let remix IDE know which version of the solidity compiler solc to use when compiling this smart contract.
//Note that the version declared here needs to be >= 0.8.9 solc version 

/*[2]*/

//Here we begin the definition of the contract object. This class definition includes all the associated state variables, the functions and
//their method definitions along with visibility and payability restrictions when a user interacts with a deployed contract object from it.
contract MSW {


//declared variables stored by a contract are stored on-chain with the contract.
//Solidity has two main types of variables - value and reference types.
//A type's visibility is used to modify its accessibility to contract calls.

//3. Declare a publically visible array that will hold all the owners' addresses - call it 'owners'. 
    /*[3]*/

//4. Declare a publically visible mapping 'isOwner' whose key is an address and value is boolean.
    /*[4]*/

    uint256 private numConfirmationsRequired;
    uint256 private ownersLimit;
    uint256 private ownersPresent;
    uint256 private requestsWindow;
    uint256 private deployedTime;
    address private deployer;
    mapping(address => bool) public isReqOwner;


//5. Add a data field to this structure - 'numConfirmations' - which holds the number of confirmations a given transaction obtains.
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        /*[5]*/
    }
//6. Declare a public array called 'transactions' to hold transactions as defined above.
    /*[6]*/

//7. Declare a nested mapping called 'isConfirmed' from tx index => owner => boolean value, remember to nest right associatively. 
    /*[7]*/


//Events and Emits are a pub-sub pattern that are natively supported by solidity language which, in Hedera, is managed by HCS.
//They are useful for storing custom information on points of interest during code execution when we make contract function calls.

//8. Create an event called Deposit which echoes on emit an address (say sender), the amount deposited (say amount) 
//and the contract balance (say balance) declare the variable types for each appropriately
//Additionally, ensure that this event log uses the sender field for its topic.

    /*[8]*/

    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);
    
    event grantedOwnership(address indexed owner, address indexed approver, uint256 timeAdded);

//recall that modifiers are templates that can be used to enforce conditional execution on function calls. 
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

//9. This modifier should require that transaction specified by _txIndex actually exists 
//by asserting the _txIndex is within the range of public array transactions (Refer 6)
//and if not throwing an error that "tx does not exist"
    modifier txExists(uint256 _txIndex) {
    /*[9]*/
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

//10. The constructor is called when deploying the contract on the network. Infer the arguments for this constructor by reading 
//its method code and add the necessary argument declarations.
    constructor(/*[10]*/) {
        require(
            _numConfirmationsRequired > 0
                && _numConfirmationsRequired <= _ownersLimit,
            "invalid number of required confirmations"
        );
        require(_ownersLimit >= 0, "wallet needs at least one owner");
        require(_owners.length + 1 <= _ownersLimit, "invalid number of owners");

        deployedTime = block.timestamp;
        requestsWindow = _requestsWindow;
        ownersLimit = _ownersLimit;

        deployer = msg.sender;
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
        ownersPresent = 1;

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
            ownersPresent += 1;
        }

        numConfirmationsRequired = _numConfirmationsRequired;
        ownersLimit = _ownersLimit;
    }

    receive() external payable {
//11. when this function is triggered (i.e., by a payment call), 
// it should emit the Deposit event you defined earlier (Refer 8). 
// The log should contain the sender's address, amount deposited and the current contract balance.
    
        /*[11]*/
    }

//12. modify this function so that only wallet owners can successfully invoke it.
    function submitTransaction(address _to, uint256 _value, bytes memory _data)
        public
    /*[12]*/
    {
        uint256 txIndex = transactions.length;
//13. Below we append this incoming transaction request into the transactions array
        transactions.push(
            /*[13]*/
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        // 14. Declare a reference type called transaction to the one stored in the contract that belongs to this _txIndex. 
        /*[14]*/

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success,) =
            transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

//15. Add the necessary modifiers using those we have defined already. 
    function revokeConfirmation(uint256 _txIndex)
        public
        /*[15]*/
    {
//16. Complete the logic for revoking a transactions confirmation from its caller using the 'executeTransaction' method as your guidance.


        /*[16]*/

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }


    function getTransactionCount() 
    public view 
    returns (uint256) {
        return transactions.length;
    }


//17. In this function, any user can request ownership access for a fixed period of time from the contracts deployment.
//Filling the missing conditionals in each of the require statements - which on failure throw the accompanying error message
    function requestOwnership() 
    public 
    returns (uint256)
    {
        require(/*[17A]*/, "already an owner");
        require(/*[17B]*/, "already requested owner access");
        require(/*[17C]*/, "owners limit reached");
        require(/*[17D]*/, "requesting window closed");
        isReqOwner[msg.sender] = true;
        return (block.timestamp - deployedTime);
    }

    function grantOwnership(address _addowner) 
        public
        onlyOwner
    {
        require(isReqOwner[_addowner], "did not request owner access");
        require(ownersPresent + 1 <= ownersLimit, "owners limit reached");
        require(!isOwner[_addowner], "owner not unique");
        require(_addowner != address(0), "invalid owner");

        isOwner[_addowner] = true;
        owners.push(_addowner);
        ownersPresent += 1;
        emit grantedOwnership(_addowner, msg.sender, block.timestamp);
    }

    function getTransaction(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
    function getBalance() 
        external view 
        onlyOwner
        returns (uint256) 
    
    {
        return address(this).balance;
    }
}
