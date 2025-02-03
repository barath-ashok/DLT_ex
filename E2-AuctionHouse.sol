//This file serves as the 2nd guided exercise for learning smart contract programming using the solidity language
//It is best worked with in an interactive manner (via a code editor) where the user opens on a copy of this file and
//edits the file by reading the comments, such as this one. Each guiding comment is numbered starting from 1,2,3,...,etc,. and
//associated with each numbered comment is a fixed-format comment "/*[X]*/" (by itself or in a line of code) where you are 
//expected to supply a code fragment or keyword - thereby "solving" the prior comment. 
//This file has a total of N=5 comments.
/*------------------------------------------------------------------------------------*/
/*---------------------We begin---------------------*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//Interfaces are commonly used to specify and abstract contract definitions. 
//It is a set of supported methods (specified through signatures)
//It is a systematic way to decouple implementation details which can change in the future from the top-level method definition.
//For example, IERC721 is a system-level interface which specifies an NFT object.
//[1]. Read the contract to find out what functions of an NFT are used. Then Add their method signature(s). 
interface IERC721 {
    /*[1]*/
}

contract AuctionHouse {

    event Deposit(address indexed sender, uint256 amount, uint256 balance);
	address public owner;
    //a user-defined cryptographic salt. (sometimes also called Number used only once i.e., 'Nonce')
	bytes32 public salt;
	//seller => Items List
	mapping (address => bool) liveAuctionsByContract;
	
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

	constructor (string memory _salt)
	{
        //this call converts the user input given as a variable length string
        //and encodes it into a bytes32 salt (i.e., fixed length) 
		salt = keccak256(abi.encodePacked(_salt));
		owner = msg.sender;
	}
    function getBalance() 
        external view 
        returns (uint256)   
    {
        return address(this).balance;
    }

//The following function computes the bytecode of a contract at creation time
    function getBytecode(address _nft, uint256 _nftId, address _seller)
        public
        pure
        returns (bytes memory)
    {
        //[2]. the variabe bytecode below should be assigned the 'CreationCode' from the contract class 'EnglishAuction'
        //This contract object is defined below in this file, below this contract class.
		//Use its information and the variable typing function 'type()' to solve this exercise.
        bytes memory bytecode = /*[2]*/;
        
		//This is then used for abi encoding the CreationCode with the constructor arguments
        //The encoding is Non-standard "packed" mode 
        //This will become associated with each deployed EnglishAuction instance
        return abi.encodePacked(bytecode, abi.encode(_nft, _nftId, _seller));
    }

    // This function Compute the address of the contract to be deployed
    // NOTE: In the most general setting, _salt is some random number used to aid creation of address for contractual deployment.
    function getAddress(bytes memory bytecode, bytes32 _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            //[3]. specify the abi method to encode the arguments below 
            //Note that this has to be non-standard packed mode of contract ABI specification.
            /*[3]*/(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
			//The reference for this is solidity docs which comes in handy when working with ABI encoding and decoding.
            )
        );

        //Understand where in the casting here results in the last 20 bytes of the hash used for address
        return address(uint160(uint256(hash)));
    }

	function requestNewAuction(address _sellerAddress, address _nft, uint256 _nftId)
	external 
	returns (address) {

			bytes memory byteCode = getBytecode(_nft, _nftId, _sellerAddress);
			address checkAddress = getAddress(byteCode, salt);
            //[4]. complete the below conditional which checks if this NFT by this seller is already on sale 
			//by checking the address to be deployed against existing live auctions
			require(/*[4]*/, "this NFT by Seller is currently on sale!");
            //the new keyword is used to deploy contracts programatically, below we are creating an English Auction.
            //[5]. complete the assignment below by using the same salt used to create "checkAddress" 
            //ensure you pass the constructor arguments for nft, nftId and seller
			EnglishAuction newAuction = new /*[5]*/;
			address newContractAddress = address(newAuction);
			liveAuctionsByContract[newContractAddress] = true;
			return(newContractAddress);

		}
	}

    contract EnglishAuction {

		event Deposit(address indexed sender, uint256 amount, uint256 balance);
		event Start();
		event Bid(address indexed sender, uint256 amount);
		event Withdraw(address indexed bidder, uint256 amount);
		event End(address winner, uint256 amount);

		IERC721 public nft;
		uint256 public nftId;
		
		address payable public seller;
		uint256 public endAt;
		bool public started;
		bool public ended;

		address public highestBidder;
		uint256 public highestBid;
		uint256 public bankBid;
		mapping(address => uint256) public bids;

	    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
	    }

		constructor(address _nft, uint256 _nftId, address _seller) {
			nft = IERC721(_nft);
			nftId = _nftId;

			seller = payable(_seller);
		}


		function start(uint256 _startingBid, uint256 _bankBid) external {
			require(!started, "started");
			require(msg.sender == seller, "not seller");
			require(_bankBid > _startingBid, "bank bid not larger than starting bid!");
			highestBid = _startingBid;
			nft.transferFrom(msg.sender, address(this), nftId);
			started = true;
			endAt = block.timestamp + 7 days;
			bankBid = _bankBid;

			emit Start();
		}

		function bid() external payable {
			require(started, "not started");
			require(block.timestamp < endAt, "ended");
			require(msg.value > highestBid, "value < highest");

			if (highestBidder != address(0)) {
				bids[highestBidder] += highestBid;
			}

			highestBidder = msg.sender;
			highestBid = msg.value;

			emit Bid(msg.sender, msg.value);
		}

		function withdraw() external {
			uint256 bal = bids[msg.sender];
			bids[msg.sender] = 0;
			payable(msg.sender).transfer(bal);

			emit Withdraw(msg.sender, bal);
		}

		function end() external {
			require(started, "not started");
			require((block.timestamp >= endAt || highestBid > bankBid), "not ended");
			require(!ended, "ended");

			ended = true;
			if (highestBidder != address(0)) {
				nft.transferFrom(address(this), highestBidder, nftId);
				seller.transfer(highestBid);
			} else {
				nft.transferFrom(address(this), seller, nftId);
			}

			emit End(highestBidder, highestBid);
		}
    }
