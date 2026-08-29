//
//  TextExample.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct TextForegroundExample: View {
    var body: some View {
        VStack {
            Text("Hello World")
            Text("From OpenSwiftUI")
                .foregroundStyle(.red)
        }
    }
}

struct TextFormatStyleExample: View {
    @State private var myDate = Date(timeIntervalSince1970: 1_767_225_600)

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    var body: some View {
        VStack {
            Text(myDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
            Text(myDate, format: Date.FormatStyle(date: .complete, time: .complete))
            Text(myDate, format: Date.FormatStyle().hour(.defaultDigitsNoAMPM).minute())
        }
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
        .environment(\.calendar, calendar)
        .environment(\.timeZone, calendar.timeZone)
    }
}

struct TextSystemFormatStyleExample: View {
    private let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
    private let showsHoursVariants = [true, false]

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    var body: some View {
        let end = start.addingTimeInterval(7_200)
        let futureStart = Date(timeIntervalSince1970: 4_102_444_800)
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                ForEach(showsHoursVariants, id: \.self) { showsHours in
                    Text(
                        start.addingTimeInterval(3_665),
                        format: SystemFormatStyle.Timer.timer(
                            countingUpIn: start..<end,
                            showsHours: showsHours,
                            maxPrecision: .seconds(1)
                        )
                    )
                }
            }
            HStack(spacing: 16) {
                ForEach(showsHoursVariants, id: \.self) { showsHours in
                    Text(
                        start.addingTimeInterval(65),
                        format: SystemFormatStyle.Timer.timer(
                            countingDownIn: start..<end,
                            showsHours: showsHours,
                            maxPrecision: .seconds(1)
                        )
                    )
                }
            }
            HStack(spacing: 16) {
                ForEach(showsHoursVariants, id: \.self) { showsHours in
                    Text(
                        start.addingTimeInterval(3_665),
                        format: SystemFormatStyle.Stopwatch.stopwatch(
                            startingAt: start,
                            showsHours: showsHours,
                            maxPrecision: .seconds(1)
                        )
                    )
                }
            }
            Text(
                start.addingTimeInterval(90),
                format: SystemFormatStyle.DateOffset.offset(
                    to: start,
                    allowedFields: [.minute, .second],
                    maxFieldCount: 2,
                    sign: .always(includingZero: false)
                )
            )
            Text(
                start.addingTimeInterval(90 * 60),
                format: SystemFormatStyle.DateReference.reference(
                    to: start,
                    allowedFields: [.day, .hour, .minute],
                    maxFieldCount: 2,
                    thresholdField: .day
                )
            )
            Text(
                futureStart.addingTimeInterval(65),
                format: SystemFormatStyle.Stopwatch.stopwatch(
                    startingAt: futureStart,
                    maxPrecision: .seconds(1)
                )
            )
        }
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
        .environment(\.calendar, calendar)
        .environment(\.timeZone, calendar.timeZone)
        .padding()
    }
}

struct TextBackgroundHeightExample: View {
    var body: some View {
        Text("Hello, world!")
            .background(Color.red)
    }
}

#Preview("TextForegroundExample") {
    TextForegroundExample()
}

#Preview("TextFormatStyleExample") {
    TextFormatStyleExample()
}

#Preview("TextSystemFormatStyleExample") {
    TextSystemFormatStyleExample()
}

#Preview("TextBackgroundHeightExample") {
    TextBackgroundHeightExample()
}
