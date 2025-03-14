{-# LANGUAGE OverloadedStrings #-}

module Plutarch.Core.Integrity (
  pisScriptCredential,
  pisPubKeyCredential,
  pdeserializeCredential,
  pisVotingScript,
  pisProposingScript,
  pisCertifyingScript,
  pisMintingScript,
  pisSpendingScript,
  pisRewardingScript,
) where

import Plutarch.Core.List (pheadSingleton)
import Plutarch.LedgerApi.V3 (PCredential, PScriptInfo)
import Plutarch.Prelude (PAsData, PBool, PEq ((#==)), Term, pasByteStr,
                         pasConstr, pcond, perror, pforgetData, pfstBuiltin,
                         pif, plengthBS, plet, psndBuiltin, ptraceInfoError,
                         (#))

-- | Check that a data-encoded Credential is a ScriptCredential.
-- This does not guarantee that the data-encoded term is structurally a valid Credential.
-- So this should only be used if the data-encoded term is known to be a Credential.
-- If the term is obtained from relevant fields of the ScriptContext or TxInfo, then this check is safe
-- because the ledger guarantees the structural validity of the Credential.
pisScriptCredential :: Term s (PAsData PCredential) -> Term s PBool
pisScriptCredential cred = (pfstBuiltin # (pasConstr # pforgetData cred)) #== 1

-- | Check if the provided data-encoded Credential is a PubKeyCredential.
-- This does not guarantee that the data-encoded term is structurally a valid Credential.
-- So this should only be used if the data-encoded term is known to be a Credential.
-- If the term is obtained from relevant fields of the ScriptContext or TxInfo, then this check is safe
-- because the ledger guarantees the structural validity of the Credential.
pisPubKeyCredential :: Term s (PAsData PCredential) -> Term s PBool
pisPubKeyCredential cred = (pfstBuiltin # (pasConstr # pforgetData cred)) #== 0

-- | Check if the provided data-encoded term has the expected builtin data representation of a credential.
pdeserializeCredential :: Term s (PAsData PCredential) -> Term s (PAsData PCredential)
pdeserializeCredential term =
  plet (pasConstr # pforgetData term) $ \constrPair ->
    plet (pfstBuiltin # constrPair) $ \constrIdx ->
      pif (plengthBS # (pasByteStr # (pheadSingleton # (psndBuiltin # constrPair))) #== 28)
          (
            pcond
              [ ( constrIdx #== 0 , term)
              , ( constrIdx #== 1 , term)
              ]
              (ptraceInfoError "Invalid credential")
          )
          perror

-- | Check the script info to determine if the script is being executed as a minting script.
pisMintingScript :: Term s (PAsData PScriptInfo) -> Term s PBool
pisMintingScript term = (pfstBuiltin # (pasConstr # pforgetData term)) #== 0

-- | Check the script info to determine if the script is being executed as a spending script.
pisSpendingScript :: Term s (PAsData PScriptInfo) -> Term s PBool
pisSpendingScript term = (pfstBuiltin # (pasConstr # pforgetData term)) #== 1

-- | Check the script info to determine if the script is being executed as a rewarding script.
pisRewardingScript :: Term s (PAsData PScriptInfo) -> Term s PBool
pisRewardingScript term = (pfstBuiltin # (pasConstr # pforgetData term)) #== 2

-- | Check the script info to determine if the script is being executed as a certifying script.
pisCertifyingScript :: Term s (PAsData PScriptInfo) -> Term s PBool
pisCertifyingScript term = (pfstBuiltin # (pasConstr # pforgetData term)) #== 3

-- | Check the script info to determine if the script is being executed as a voting script.
pisVotingScript :: Term s (PAsData PScriptInfo) -> Term s PBool
pisVotingScript term = (pfstBuiltin # (pasConstr # pforgetData term)) #== 4

-- | Check the script info to determine if the script is being executed as a proposing script.
pisProposingScript :: Term s (PAsData PScriptInfo) -> Term s PBool
pisProposingScript term = (pfstBuiltin # (pasConstr # pforgetData term)) #== 5
