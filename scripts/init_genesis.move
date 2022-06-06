script {
    use AptosFramework::Genesis;

    /// Script which initializes Aptos Framework genesis state.
    /// Required to call before work with Aptos Framework related contracts.
    fun init_genesis(s: signer) {
      Genesis::setup(&s);
    }
}