//
//  SpacingLayout.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenCoreGraphicsShims

struct SpacingLayout: UnaryLayout {
    var spacing: Spacing

    func spacing(in context: SizeAndSpacingContext, child: LayoutProxy) -> Spacing {
        spacing
    }

    func placement(of child: LayoutProxy, in context: PlacementContext) -> _Placement {
        _Placement(
            proposedSize: context.proposedSize,
            aligning: .center,
            in: context.size
        )
    }

    func sizeThatFits(in proposedSize: _ProposedSize, context: SizeAndSpacingContext, child: LayoutProxy) -> CGSize {
        child.size(in: proposedSize)
    }
}

extension View {
    package func spacing(_ spacing: Spacing) -> some View {
        modifier(SpacingLayout(spacing: spacing))
    }
}
