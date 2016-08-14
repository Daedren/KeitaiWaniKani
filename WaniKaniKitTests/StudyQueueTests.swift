//
//  SRSDataItemTests.swift
//  WaniKaniKit
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import XCTest
@testable import WaniKaniKit

class StudyQueueTests: XCTestCase {
    
    func testReviewDateSameDaySameTime() {
        let referenceDate = date(2015, 1, 1, 12, 30, 34)
        let nextReviewDate = date(2015, 1, 1, 12, 30, 34)
        
        let studyQueue = StudyQueue(lessonsAvailable: 1, reviewsAvailable: 0, nextReviewDate: nextReviewDate, reviewsAvailableNextHour: 0, reviewsAvailableNextDay: 0)
        let formattedNextReviewDate = studyQueue.formattedNextReviewDate(referenceDate)
        XCTAssertEqual(formattedNextReviewDate, formatTimeOnly(nextReviewDate))
    }
    
    func testReviewDateSameDayDifferentTime() {
        let referenceDate = date(2015, 1, 1, 12, 30, 34)
        let nextReviewDate = date(2015, 1, 1, 18, 0, 15)
        
        let studyQueue = StudyQueue(lessonsAvailable: 1, reviewsAvailable: 0, nextReviewDate: nextReviewDate, reviewsAvailableNextHour: 0, reviewsAvailableNextDay: 0)
        let formattedNextReviewDate = studyQueue.formattedNextReviewDate(referenceDate)
        XCTAssertEqual(formattedNextReviewDate, formatTimeOnly(nextReviewDate))
    }
    
    func testReviewDateNextDayMidnight() {
        let referenceDate = date(2015, 1, 1, 12, 30, 34)
        let nextReviewDate = date(2015, 1, 2, 0, 0, 0)
        
        let studyQueue = StudyQueue(lessonsAvailable: 1, reviewsAvailable: 0, nextReviewDate: nextReviewDate, reviewsAvailableNextHour: 0, reviewsAvailableNextDay: 0)
        let formattedNextReviewDate = studyQueue.formattedNextReviewDate(referenceDate)
        XCTAssertEqual(formattedNextReviewDate, formatDateTime(nextReviewDate))
    }
    
    func testReviewDateNextDaySameTime() {
        let referenceDate = date(2015, 1, 1, 12, 30, 34)
        let nextReviewDate = date(2015, 1, 2, 12, 30, 34)
        
        let studyQueue = StudyQueue(lessonsAvailable: 1, reviewsAvailable: 0, nextReviewDate: nextReviewDate, reviewsAvailableNextHour: 0, reviewsAvailableNextDay: 0)
        let formattedNextReviewDate = studyQueue.formattedNextReviewDate(referenceDate)
        XCTAssertEqual(formattedNextReviewDate, formatDateTime(nextReviewDate))
    }
    
    func testReviewDateNextDayDifferentTime() {
        let referenceDate = date(2015, 1, 1, 12, 30, 34)
        let nextReviewDate = date(2015, 1, 2, 18, 0, 15)
        
        let studyQueue = StudyQueue(lessonsAvailable: 1, reviewsAvailable: 0, nextReviewDate: nextReviewDate, reviewsAvailableNextHour: 0, reviewsAvailableNextDay: 0)
        let formattedNextReviewDate = studyQueue.formattedNextReviewDate(referenceDate)
        XCTAssertEqual(formattedNextReviewDate, formatDateTime(nextReviewDate))
    }
    
    private func formatDateTime(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
    
    private func formatTimeOnly(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }
    
}
