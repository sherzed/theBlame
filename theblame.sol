//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract UBXS_nftStake {
    using SafeMath for uint256;
    IERC20 private UBXS;
    uint256 constant INVEST_MIN_AMOUNT = 50000; // 6 Decimals = 0.05 UBXS
    uint256 constant TIME_STEP = 1 days;
    uint256[] public referralPercents = [20, 18, 16, 13, 12, 10, 6, 4, 2, 1];
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public totalInvested;

    modifier onlyOwner(){
            require(msg.sender == owner);
            _;
    }
    
    constructor(address tokenAddress) public {
      owner = msg.sender;
      UBXS = IERC20(tokenAddress); 
    }

    address owner;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Action {
        uint8 types;
        uint256 amount;
        uint256 date;
    }

     struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
    }

    struct User {
        //Kimin referansı ile kayıt oldugu
        address[] referrers;
        //time
        uint256 checkpoint;
        uint256[10] levels;
        //Referans bonus
        uint256 totalBonus;
        uint256 withdrawn;
        uint256 bonus;
        Action[] actions;
        Deposit[] deposits;
    }

    mapping(address => User) public users;

    bool  public  status;

    function invest(address _referrer, uint256 tokenAmount) public {
        uint256 _tokenAmount = tokenAmount * 10**6;
        require(_tokenAmount>=INVEST_MIN_AMOUNT);
        User storage user = users[msg.sender];
        if(_referrer!=address(0)){
        User storage referancer = users[_referrer];
        referancer.referrers.push(msg.sender);
        // Action  
        referancer.actions.push(Action(1, _tokenAmount, block.timestamp));
        // Referans kodundaki kullaniciya total bonus arttıracak.
        }
        else{
        require( 
          UBXS.transferFrom(msg.sender, address(thisl), tokenAmount),
          "Transaction Error!"
        );
        }
    }

    function reInvest() public {
        User storage user = users[msg.sender];
        uint256 totalAmount = getUserDividends(msg.sender);
        user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAmount);
        user.deposits.push(Deposit(1, totalAmount, block.timestamp));
        user.actions.push(Action(2, totalAmount, block.timestamp));
        totalInvested = totalInvested.add(totalAmount);
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 totalAmount = getUserDividends(msg.sender);
        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            user.bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }

        require(totalAmount > 0, "User has no dividends");
        uint256 contractBalance = address(this).balance;

        if (contractBalance < totalAmount) {
            user.bonus = totalAmount.sub(contractBalance);
            user.totalBonus = user.totalBonus.add(user.bonus);
            totalAmount = contractBalance;
        }
        user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAmount);
        require( 
          UBXS.transferFrom(address(this), msg.sender, totalAmount),
          "Transaction Error!"
        );
        user.actions.push(Action(1, totalAmount, block.timestamp));
    }
    function destroyContract(address payable _address) public onlyOwner {
        selfdestruct(_address);
    }

    function changeStatus(bool _status) public onlyOwner {
        status = _status; 
    }

    function getUserDividends(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish = user.deposits[i].start.add(
                plans[user.deposits[i].plan].time.mul(TIME_STEP)
            );
            if (user.checkpoint < finish) {
                uint256 share = user
                    .deposits[i]
                    .amount
                    .mul(plans[user.deposits[i].plan].percent)
                    .div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = finish < block.timestamp ? finish : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
                }
            }
        }
        return totalAmount;
    }

    function getUserReferralBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].bonus;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
