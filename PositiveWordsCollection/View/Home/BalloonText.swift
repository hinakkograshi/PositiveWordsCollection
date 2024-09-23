//
//  BalloonText.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/12.
//

import SwiftUI

struct BalloonText: View {
    let text: String
    let color: Color
    let mirrored: Bool

    init(_ text: String,
         color: Color = Color(UIColor(red: 109 / 255, green: 230 / 255, blue: 123 / 255, alpha: 1.0)),
         mirrored: Bool = false
    ) {
        self.text = text
        self.color = color
        self.mirrored = mirrored
    }

    var body: some View {
        let cornerRadius = 8.0

        Text(text)
            .padding(.leading, 4 + (mirrored ? cornerRadius / 2 : 0))
            .padding(.trailing, 4 + (!mirrored ? cornerRadius / 2 : 0))
            .padding(.vertical, 6)
            .background(BalloonShape(
                            cornerRadius: cornerRadius,
                            color: color,
                            mirrored: mirrored)
            )
    }
}

struct BalloonShape: View {
    var cornerRadius: Double
    var color: Color
    var mirrored = false

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let tailSize = CGSize(
                    width: cornerRadius / 2,
                    height: cornerRadius / 2)
                let shapeRect = CGRect(
                    x: 0,
                    y: 0,
                    width: geometry.size.width,
                    height: geometry.size.height)

                // 時計まわりに描いていく

                // 左上角丸
                path.addArc(
                    center: CGPoint(
                        x: shapeRect.minX + cornerRadius,
                        y: shapeRect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 279), clockwise: false)

                // 右上角丸
                path.addArc(
                    center: CGPoint(
                        x: shapeRect.maxX - cornerRadius - tailSize.width,
                        y: shapeRect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 270 + 45), clockwise: false)

                // しっぽ上部
                path.addQuadCurve(
                    to: CGPoint(
                        x: shapeRect.maxX,
                        y: shapeRect.minY),
                    control: CGPoint(
                        x: shapeRect.maxX - (tailSize.width / 2),
                        y: shapeRect.minY))

                // しっぽ下部
                path.addQuadCurve(
                    to: CGPoint(
                        x: shapeRect.maxX - tailSize.width,
                        y: shapeRect.minY + (cornerRadius / 2) + tailSize.height),
                    control: CGPoint(
                        x: shapeRect.maxX - (tailSize.width / 2),
                        y: shapeRect.minY))

                // 右下角丸
                path.addArc(
                    center: CGPoint(
                        x: shapeRect.maxX - cornerRadius - tailSize.width,
                        y: shapeRect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90), clockwise: false)

                // 左下角丸
                path.addArc(
                    center: CGPoint(
                        x: shapeRect.minX + cornerRadius,
                        y: shapeRect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180), clockwise: false)
            }
            .fill(self.color)
            .rotation3DEffect(.degrees(mirrored ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        }
    }
}

#Preview {
    BalloonText("考古jぃ亜shんxrボエcbrtcbt根rぉyzのんの考古jぃ亜shんxrボエcbrtcbt根rぉyzのんの")
}
