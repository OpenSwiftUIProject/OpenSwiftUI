//
//  AccessibilityDataSeries.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D54125E3A4CDE7D8F0604D8A75122DE8 (SwiftUICore)

// MARK: - AccessibilityDataSeriesConfiguration

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public struct AccessibilityDataSeriesConfiguration {
    public struct ValueDescription {
        public var description: Text
        public var effectiveValueRange: Range<Double>

        public init(description: Text, effectiveValueRange: Range<Double>) {
            self.description = description
            self.effectiveValueRange = effectiveValueRange
        }
    }

    public struct AxisConfiguration {
        public var title: Text?
        public var unitLabel: Text?
        public var categoryLabels: [Text]
        public var minimumValue: Double?
        public var maximumValue: Double?
        public var gridlinePositions: [Double]
        public var values: [Double]
        public var valueDescriptions: [ValueDescription]

        public init(
            title: Text? = nil,
            unitLabel: Text? = nil,
            categoryLabels: [Text] = [],
            minimumValue: Double? = nil,
            maximumValue: Double? = nil,
            gridlinePositions: [Double] = [],
            values: [Double] = [],
            valueDescriptions: [ValueDescription] = []
        ) {
            self.title = title
            self.unitLabel = unitLabel
            self.categoryLabels = categoryLabels
            self.minimumValue = minimumValue
            self.maximumValue = maximumValue
            self.gridlinePositions = gridlinePositions
            self.values = values
            self.valueDescriptions = valueDescriptions
        }
    }

    public enum DataSeriesType: Int, Codable {
        case scatter
        case line
        case bar
    }

    public var name: Text
    public var type: DataSeriesType
    public var supportsSonification: Bool
    public var sonificationDuration: Double?
    public var includesTrendlineInSonification: Bool
    public var supportsSummarization: Bool
    public var xAxisConfiguration: AxisConfiguration?
    public var yAxisConfiguration: AxisConfiguration?

    public init(
        name: Text,
        type: DataSeriesType,
        supportsSonification: Bool = false,
        sonificationDuration: Double? = nil,
        includesTrendlineInSonification: Bool = false,
        supportsSummarization: Bool = false,
        xAxisConfiguration: AxisConfiguration? = nil,
        yAxisConfiguration: AxisConfiguration? = nil
    ) {
        self.name = name
        self.type = type
        self.supportsSonification = supportsSonification
        self.sonificationDuration = sonificationDuration
        self.includesTrendlineInSonification = includesTrendlineInSonification
        self.supportsSummarization = supportsSummarization
        self.xAxisConfiguration = xAxisConfiguration
        self.yAxisConfiguration = yAxisConfiguration
    }
}

@_spi(Private)
@available(*, unavailable)
extension AccessibilityDataSeriesConfiguration.ValueDescription: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension AccessibilityDataSeriesConfiguration.AxisConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension AccessibilityDataSeriesConfiguration.DataSeriesType: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension AccessibilityDataSeriesConfiguration: Sendable {}

// MARK: - CodableAccessibilityDataSeriesConfiguration

struct CodableAccessibilityDataSeriesConfiguration: Codable {
    struct ValueDescription: Codable {
        var description: CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>?
        var effectiveValueRange: Range<Double>
    }

    struct AxisConfiguration: Codable {
        var title: CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>?
        var unitLabel: CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>?
        var categoryLabels: [CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>]
        var minimumValue: Double?
        var maximumValue: Double?
        var gridlinePositions: [Double]
        var values: [Double]
        var valueDescriptions: [ValueDescription]

        init(_ configuration: AccessibilityDataSeriesConfiguration.AxisConfiguration, in environment: EnvironmentValues) {
            title = configuration.title.flatMap {
                .init(texts: [$0], in: environment, optional: false, idiom: nil)
            }
            unitLabel = configuration.unitLabel.flatMap {
                .init(texts: [$0], in: environment, optional: false, idiom: nil)
            }
            categoryLabels = configuration.categoryLabels.compactMap {
                .init(texts: [$0], in: environment, optional: false, idiom: nil)
            }
            minimumValue = configuration.minimumValue
            maximumValue = configuration.maximumValue
            gridlinePositions = configuration.gridlinePositions
            values = configuration.values
            valueDescriptions = configuration.valueDescriptions.map {
                ValueDescription(
                    description: .init(texts: [$0.description], in: environment, optional: false, idiom: nil),
                    effectiveValueRange: $0.effectiveValueRange
                )
            }
        }

        var configuration: AccessibilityDataSeriesConfiguration.AxisConfiguration {
            .init(
                title: title?.text,
                unitLabel: unitLabel?.text,
                categoryLabels: categoryLabels.map { $0.text },
                minimumValue: minimumValue,
                maximumValue: maximumValue,
                gridlinePositions: gridlinePositions,
                values: values,
                valueDescriptions: valueDescriptions.map {
                    .init(
                        description: $0.description?.text ?? Text(verbatim: ""),
                        effectiveValueRange: $0.effectiveValueRange
                    )
                }
            )
        }
    }

    var name: CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>?
    var type: AccessibilityDataSeriesConfiguration.DataSeriesType
    var supportsSonification: Bool
    var sonificationDuration: Double?
    var includesTrendlineInSonification: Bool
    var supportsSummarization: Bool
    var xAxisConfiguration: AxisConfiguration?
    var yAxisConfiguration: AxisConfiguration?

    init(_ configuration: AccessibilityDataSeriesConfiguration, in environment: EnvironmentValues) {
        name = .init(texts: [configuration.name], in: environment, optional: false, idiom: nil)
        type = configuration.type
        supportsSonification = configuration.supportsSonification
        sonificationDuration = configuration.sonificationDuration
        includesTrendlineInSonification = configuration.includesTrendlineInSonification
        supportsSummarization = configuration.supportsSummarization
        xAxisConfiguration = configuration.xAxisConfiguration.map {
            AxisConfiguration($0, in: environment)
        }
        yAxisConfiguration = configuration.yAxisConfiguration.map {
            AxisConfiguration($0, in: environment)
        }
    }

    var configuration: AccessibilityDataSeriesConfiguration {
        .init(
            name: name?.text ?? Text(verbatim: ""),
            type: type,
            supportsSonification: supportsSonification,
            sonificationDuration: sonificationDuration,
            includesTrendlineInSonification: includesTrendlineInSonification,
            supportsSummarization: supportsSummarization,
            xAxisConfiguration: xAxisConfiguration?.configuration,
            yAxisConfiguration: yAxisConfiguration?.configuration
        )
    }
}
