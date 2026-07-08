// Simplified L1 Bridge reference contract
// Actual deployment uses op-deployer from the optimism monorepo

interface OptimismPortal {
    function depositTransaction(
        address _to,
        uint256 _value,
        uint64 _gasLimit,
        bool _isCreation,
        bytes calldata _data
    ) external payable;
}

interface L2OutputOracle {
    function getL2Output(uint256 _index)
        external
        view
        returns (bytes32 outputRoot, uint128 timestamp, uint128 l2BlockNumber);
    function latestOutputIndex() external view returns (uint256);
}

interface L1StandardBridge {
    function depositETH(
        uint256 _minGasLimit,
        bytes calldata _extraData
    ) external payable;
    function depositERC20(
        address _l1Token,
        address _l2Token,
        uint256 _amount,
        uint256 _minGasLimit,
        bytes calldata _extraData
    ) external;
}
