//
//  TweetTableViewCell.swift
//  PlatziTweets
//
//  Created by Inx on 18/04/23.
//

import UIKit
import Kingfisher// sirve para traer imagenes desde la web

class TweetTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nickNamesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //NOTA IMPORTANTE:
    //Las celdas nunca deben invocar ViewController!
    
    //MARK: - IBActions
    @IBAction func openVideoAction() {
        // entonces, siguiendo la nota. desde aquí no podemos abrir un video, así que lo que se va a hacer es avisarle a la tabla que tiene que abrir un vídeo.
        guard let videoUrl = videoUrl else{
            return
        }
        needsToShowVideo?(videoUrl)
    }
    
    //MARK: - Properties
    private var videoUrl : URL?
    // lo que se hace aquí es crear un bloque, una función opcional que va a implementar nuestra tabla para que ella sepa cuando tiene que mostrar un video
    var needsToShowVideo:  ((_ url : URL) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //
    func setupCellWith(tweet: Tweet)
    {
        videoButton.isHidden = !tweet.hasVideo// si el tweet no tiene un video, entonces nuestro boton va a estar oculto
        nameLabel.text = tweet.author.names
        nickNamesLabel.text = tweet.author.nickname
        messageLabel.text = tweet.text
        if tweet.hasImage{
            //configurar img
            // modificacion
            tweetImageView.isHidden = false
            tweetImageView.kf.setImage(with: URL(string: tweet.imageUrl))
        }else{
            tweetImageView.isHidden = true
        }
        
        videoUrl = URL(string: tweet.videoUrl)
        
    }
    
}
