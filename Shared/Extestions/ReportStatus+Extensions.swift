//
//  ReportStatus+Extensions.swift
//  IamRICH
//
//  Created by Sergey Yuryev on 19.05.2022.
//

import Foundation
import TinkoffInvestSDK

extension Tinkoff_Public_Invest_Api_Contract_V1_OrderExecutionReportStatus {
    var stringValue: String {
        switch self {
        case .executionReportStatusUnspecified:
            return "Не определена"
        case .executionReportStatusFill:
            return "Исполнена"
        case .executionReportStatusRejected:
            return "Отклонена"
        case .executionReportStatusCancelled:
            return "Отменена"
        case .executionReportStatusNew:
            return "Новая"
        case .executionReportStatusPartiallyfill:
            return "Частично исполнена"
        default:
            return "Нет информации"
        }
    }
}
