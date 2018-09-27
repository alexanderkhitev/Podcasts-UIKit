//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Eugene Karambirov on 26/09/2018.
//  Copyright © 2018 Eugene Karambirov. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {

    // MARK: - Properties
    var episode: Episode! {
        didSet {
            guard let url = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
        }
    }

    fileprivate let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()

    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)

    // MARK: - Outlets
    @IBOutlet fileprivate weak var maximizedStackView: UIStackView!
    @IBOutlet fileprivate weak var currentTimeSlider: UISlider!
    @IBOutlet fileprivate weak var currentTimeLabel: UILabel!
    @IBOutlet fileprivate weak var durationLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var authorLabel: UILabel!

    @IBOutlet fileprivate weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
        }
    }

    // MARK: - Mini player outlets
    @IBOutlet fileprivate weak var miniPlayerView: UIView!
    @IBOutlet fileprivate weak var miniEpisodeImageView: UIImageView!
    @IBOutlet fileprivate weak var miniTitleLabel: UILabel!

    @IBOutlet fileprivate weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(playPause(_:)), for: .touchUpInside)
            miniFastForwardButon.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }

    @IBOutlet fileprivate weak var miniFastForwardButon: UIButton! {
        didSet {
            miniFastForwardButon.addTarget(self, action: #selector(fastForward(_:)), for: .touchUpInside)
            miniFastForwardButon.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }

}

// MARK: - Actions
extension PlayerDetailsView {

    @IBAction fileprivate func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)

        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        player.seek(to: seekTime)
    }

    @IBAction fileprivate func dismiss(_ sender: Any) {
        let mainTabBarController = UIApplication.mainTabBarController
        mainTabBarController?.minimizePlayerDetails()
    }
    @IBAction fileprivate func playPause(_ sender: Any) {
        let button = sender as? UIButton

        if player.timeControlStatus == .paused {
            player.play()
            button?.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            enlargeEpisodeImageView()
            setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            button?.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            setupElapsedTime(playbackRate: 0)
        }
    }
    @IBAction fileprivate func rewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    @IBAction fileprivate func fastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)

    }
    @IBAction fileprivate func changeVolume(_ sender: UISlider) {
        player.volume = sender.value
    }

}

extension PlayerDetailsView {

    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }

    fileprivate func seekToCurrentTime(delta: Int64) {
        let seconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), seconds)
    }

    fileprivate func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }

    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }

    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrunkenTransform
        })
    }

}
