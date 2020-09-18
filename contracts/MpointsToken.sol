pragma solidity 0.6.6;

import "./ERC20/ERC20.sol";
import "./ERC20/SafeERC20.sol";
import "./libs/SafeMath.sol";

contract MpointsToken is ERC20 {
    
    struct stakeTracker {
        uint256 lastBlockChecked;
        uint256 rewards;
        uint256 mafiStaked;
    }

    address private owner;
    
    uint256 private rewardsVar;
    
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
 
    address private mafiAddress;
    IERC20 private mafiToken;

    uint256 private _totalMafiStaked;
    mapping(address => stakeTracker) private _stakedBalances;
    
    constructor() public ERC20("Mpoints", "MPO") {
        owner = msg.sender;
        _mint(msg.sender, 1000 * (10 ** 18));
        rewardsVar = 100000;
    }
    
    event Staked(address indexed user, uint256 amount, uint256 totalMafiStaked);
    event Withdrawn(address indexed user, uint256 amount);
    event Rewards(address indexed user, uint256 reward);
    
    modifier _onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier updateStakingReward(address _account) {
        if (block.number > _stakedBalances[_account].lastBlockChecked) {
            uint256 rewardBlocks = block.number.sub(
                _stakedBalances[_account].lastBlockChecked
            );
                                        
            if (_stakedBalances[_account].mafiStaked > 0) {
                _stakedBalances[_account].rewards = _stakedBalances[_account].rewards.add(
                    _stakedBalances[_account].mafiStaked.mul(rewardBlocks) / rewardsVar
                );
            }
                    
            _stakedBalances[_account].lastBlockChecked = block.number;
            
            emit Rewards(_account, _stakedBalances[_account].rewards);
        }
        _;
    }

    /**
     * @dev Check owner
     */
    function isOwner() public view returns (bool){
        return msg.sender == owner;
    }

    /**
     * @dev Set Mafi Token Address
     * @param _mafiAddress address
     */
    function setMafiAddress(address _mafiAddress) public _onlyOwner {
        mafiAddress = _mafiAddress;
        mafiToken = IERC20(_mafiAddress);
    }

    /**
     * @dev Update staking reward
     * @param _account address
     */
    function updatingStakingReward(address _account) public returns(uint256) {
        if (block.number > _stakedBalances[_account].lastBlockChecked) {
            uint256 rewardBlocks = block.number.sub(
                _stakedBalances[_account].lastBlockChecked
            );
                                        
            if (_stakedBalances[_account].mafiStaked > 0) {
                _stakedBalances[_account].rewards = _stakedBalances[_account].rewards.add(
                    _stakedBalances[_account].mafiStaked.mul(rewardBlocks) / rewardsVar
                );
            }
                                                
            _stakedBalances[_account].lastBlockChecked = block.number;

            emit Rewards(_account, _stakedBalances[_account].rewards);
        }
        return(_stakedBalances[_account].rewards);
    }

    /**
     * @dev Get Block Number
     */
    function getBlockNum() public view returns (uint256) {
        return block.number;
    }

    /**
     * @dev Get last block checked number of a given address
     * @param _account address
     */
    function getLastBlockCheckedNum(address _account) public view returns (uint256) {
        return _stakedBalances[_account].lastBlockChecked;
    }

    /**
     * @dev Get stake amount of a given address
     * @param _account address
     */
    function getAddressStakeAmount(address _account) public view returns (uint256) {
        return _stakedBalances[_account].mafiStaked;
    }

    /**
     * @dev Set reward amount
     * @param _amount uint256
     */
    function setRewardsVar(uint256 _amount) public _onlyOwner {
        rewardsVar = _amount;
    }

    /**
     * @dev return total stacked amount
     */
    function totalStakedSupply() public view returns (uint256) {
        return _totalMafiStaked;
    }

    /**
     * @dev return reward balance of a given address
     * @param _account address
     */
    function myRewardsBalance(address _account) public view returns (uint256) {
        if (block.number > _stakedBalances[_account].lastBlockChecked) {
            uint256 rewardBlocks = block.number.sub(
                _stakedBalances[_account].lastBlockChecked
            );

            if (_stakedBalances[_account].mafiStaked > 0) {
                return _stakedBalances[_account].rewards.add(
                    _stakedBalances[_account].mafiStaked.mul(rewardBlocks)/ rewardsVar
                );
            }
            return 0;
        }
        return 0;
    }

    /**
     * @dev Stake
     * @param _amount uint256
     */
    function stake(uint256 _amount) public updateStakingReward(msg.sender) {
        _totalMafiStaked = _totalMafiStaked.add(_amount);
        _stakedBalances[msg.sender].mafiStaked = _stakedBalances[msg.sender].mafiStaked.add(_amount);
        mafiToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount, _totalMafiStaked);
    }

    /**
     * @dev Withdraw
     * @param _amount uint256
     */
    function withdraw(uint256 _amount) public updateStakingReward(msg.sender) {
        _totalMafiStaked = _totalMafiStaked.sub(_amount);
        _stakedBalances[msg.sender].mafiStaked = _stakedBalances[msg.sender].mafiStaked.sub(_amount);
        mafiToken.safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    /**
     * @dev Get reward
     */
    function getReward() public updateStakingReward(msg.sender) {
       uint256 reward = _stakedBalances[msg.sender].rewards;
       _stakedBalances[msg.sender].rewards = 0;
       _mint(msg.sender, reward.mul(8) / 10);
       uint256 fundingPoolReward = reward.mul(2) / 10;
       _mint(mafiAddress, fundingPoolReward);
       emit Rewards(msg.sender, reward);
    }
}
