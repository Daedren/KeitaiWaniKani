//
//  GetVocabularyOperation.swift
//  WaniKaniKit
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import Foundation
import FMDB
import OperationKit

public final class GetVocabularyOperation: GetListItemResourceOperation<VocabularyCoder> {
    private static let runTimeoutInSeconds = 60.0
    
    public init(resolver: ResourceResolver, databaseQueue: FMDatabaseQueue, downloadStrategy: DownloadStrategy, networkObserver: OperationObserver? = nil) {
        super.init(coder: Vocabulary.coder, resolver: resolver, databaseQueue: databaseQueue, networkObserver: networkObserver, batchesForCoder: downloadStrategy.batchesForCoder)
        
        addObserver(TimeoutObserver(timeout: self.dynamicType.runTimeoutInSeconds))
    }
}
