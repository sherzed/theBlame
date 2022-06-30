// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract theBlame {
    IERC20 private blameCoin; 

    constructor(address payable tokenAddress) {
        blameCoin = IERC20(tokenAddress); 
    }
    uint256 constant PRICE = 10000000; //10 BLAME
    string [] descBlame;
    string [] users; //user names
    uint256 public blameCount = 0;
    uint256 public arrayLength = 0;
    uint256 [] boosts;
    uint256 [] blameId;
    address[] public blameOwner; //see blame owner by id

    error AlreadyClaimed();

    struct Claimer{
        uint256 claimed;
        uint256 earnedCoin;
    }
    mapping(address => Claimer) public userClaimed;

    function getBlameDetail(uint256 _id) public view returns (string memory, string memory, uint256, uint256) {
        return (users[_id],descBlame[_id], boosts[_id], blameId[_id]);
    }

    function createBlame(string memory userName, string memory yourBlame) public {
        require( 
            blameCoin.transferFrom(msg.sender, address(this), PRICE),
            "Transaction Error!"
        );
        descBlame.push(yourBlame);
        users.push(userName);
        boosts.push(0);
        blameOwner.push(msg.sender);
        blameId.push(arrayLength);
        blameCount++;
        arrayLength++;
    }

    function deleteBlame(uint256 _blameId) public {
        Claimer storage user = userClaimed[blameOwner[_blameId]];
        uint256 lastprice = (20 + boosts[_blameId] * 5) * 10**16;
        require(_blameId<=blameCount,"There is no blame for the id you specified.");
        require(
            blameCoin.transferFrom(msg.sender, address(this), lastprice),
            "Transaction Error!"
        );
        user.earnedCoin += lastprice;
        delete descBlame[_blameId];
        delete users[_blameId];
        delete boosts[_blameId];
        blameCount--;
    }

    function boostBlame(uint256 __blameId) public {
        require(__blameId<=blameCount-1,"There is no blame for the id you specified.");
        require( 
            blameCoin.transferFrom(msg.sender, address(this), 5000000),
            "Transaction Error!"
        );
        boosts[__blameId]++;
    }

    function witdhdrawEarnings() public {
        Claimer storage user = userClaimed[msg.sender];
        require( 
          blameCoin.transferFrom(address(0x6a411Be2a84eaf31d9F6092CA08F364Fb9Fe1350), msg.sender, user.earnedCoin * 10**6),
          "Transaction Error1"
          );
        user.earnedCoin = 0;
    }

    function claimBlame() public {
        Claimer storage user = userClaimed[msg.sender];
        uint256 isClaimed = user.claimed;
        require(isClaimed==0,"error");
        require( 
          blameCoin.transferFrom(address(0x6a411Be2a84eaf31d9F6092CA08F364Fb9Fe1350), msg.sender, 50000000),
          "Transaction Error!"
        );
        user.claimed = 1;
    }

    function ownerClaim(uint256 value) public {
        address _owner = 0x6a411Be2a84eaf31d9F6092CA08F364Fb9Fe1350;
        require(_owner == msg.sender,"u aren't owner");
        require( 
          blameCoin.transferFrom(address(this), address(0x6a411Be2a84eaf31d9F6092CA08F364Fb9Fe1350), value),
          "Transaction Error!"
        );
    }
 }
