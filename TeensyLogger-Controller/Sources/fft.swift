//
//  fft.swift
//  TeensyLogger-Controller
//
//  Created by Christopher Helf on 17.08.15.
//  Copyright (c) 2015-Present Christopher Helf. All rights reserved.
//  Adapted From https://gerrybeauregard.wordpress.com/2013/01/28/using-apples-vdspaccelerate-fft/
//
//  ~~~ Imported & used by Arno Jacobs on 25/07/2022.
//      Massively stripped to a bare minimum fft calculation
//      many thanks to Christopher Helf
//
//  Copyright © 2022 Open Reel Software. All rights reserved.

import Foundation
import Accelerate

class FFT {
    
    func lstSqrt(_ x: [Double]) -> [Double] {
        var results = [Double](repeating: 0.0, count: x.count)
        vvsqrt(&results, x, [Int32(x.count)])
        return results
    }
    
    func calculate(_ _values: [Double], fps: Double) -> [Double] {
        // ----------------------------------------------------------------
        // Copy of our input
        // ----------------------------------------------------------------
        let values1 = _values
        var values = values1  // need this to avoid error below
        // ----------------------------------------------------------------
        // Size Variables
        // ----------------------------------------------------------------
        let N = values.count
        let N2 = vDSP_Length(N/2)
        let LOG_N = vDSP_Length(log2(Float(values.count)))
        // ----------------------------------------------------------------
        // FFT & Variables Setup
        // ----------------------------------------------------------------
        let fftSetup: FFTSetupD = vDSP_create_fftsetupD(LOG_N, FFTRadix(kFFTRadix2))!
        var tempSplitComplexReal : [Double] = [Double](repeating: 0.0, count: N/2)
        var tempSplitComplexImag : [Double] = [Double](repeating: 0.0, count: N/2)
        var tempSplitComplex : DSPDoubleSplitComplex = DSPDoubleSplitComplex(realp: &tempSplitComplexReal, imagp: &tempSplitComplexImag)
        // ----------------------------------------------------------------
        // Forward FFT
        // ----------------------------------------------------------------
        var valuesAsComplex : UnsafeMutablePointer<DSPDoubleComplex>? = nil
        values.withUnsafeMutableBytes {
            valuesAsComplex = $0.baseAddress?.bindMemory(to: DSPDoubleComplex.self, capacity: values1.count)
        }
        // Scramble-pack the real data into complex buffer in just the way that's
        // required by the real-to-complex FFT function that follows.
        vDSP_ctozD(valuesAsComplex!, 2, &tempSplitComplex, 1, N2);
        // Do real->complex forward FFT
        vDSP_fft_zripD(fftSetup, &tempSplitComplex, 1, LOG_N, FFTDirection(FFT_FORWARD));
        // ----------------------------------------------------------------
        // Get the Frequency Spectrum
        // ----------------------------------------------------------------
        var fftMagnitudes = [Double](repeating: 0.0, count: N/2)
        vDSP_zvmagsD(&tempSplitComplex, 1, &fftMagnitudes, 1, N2);
        // vDSP_zvmagsD returns squares of the FFT magnitudes, so take the root here
        let roots = lstSqrt(fftMagnitudes)
        // Normalize the Amplitudes
        var fullSpectrum = [Double](repeating: 0.0, count: N/2)
        vDSP_vsmulD(roots, vDSP_Stride(1), [1.0 / Double(N)], &fullSpectrum, 1, N2)
        // Done. 0K.
        return fullSpectrum
    }
}
