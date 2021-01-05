module ScrapingWorkLancers

  def self.sample_function
    p "ランサーズモジュールが正しく読み込まれています。"
  end

  def self.get_work_doc(url)
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36"
    f = OpenURI.open_uri(url, { read_timeout: 300, "User-Agent" => user_agent })
    file = f.read.gsub(/<br>/, "\n")
    Nokogiri::HTML.parse(file, nil, "utf-8")
  end

  def self.fetch_work(url, doc)
    reward_min, reward_max = reward(doc)
    return {
      title: title(doc),
      url: url,
      site_type: site_type,
      reward_max: reward_max,
      reward_min: reward_min,
      detail: detail(doc),
      expired_at: expired_at(doc),
      is_finish: is_finish(doc)
    }
  end

  def self.title(doc)
    doc.at('//section[contains(@class, "section-title-group")]/h1[contains(@class, "heading--lv1")]/text()').text.strip
  end

  def self.site_type
    :lancers
  end

  def self.reward(doc)
    description = doc.at('/html/head/meta[@name="description"]')[:content]
    reward_reg = /(?<=報酬：).*?(?=\))/
    return nil, nil unless description =~ reward_reg
    reward_range = description.match(reward_reg)[0].delete("円 ").split('〜')
    min = reward_range[0] =~ /\A[0-9]+\z/ ? reward_range[0] : nil
    max = reward_range[1] =~ /\A[0-9]+\z/ ? reward_range[1] : nil
    return min, max
  end

  def self.detail(doc)
    details = doc.search('//section[contains(@class, "section-work-detail-content")]/dl[contains(@class, "c-definitionList")]').map { |dl| dl.text.strip }
    details.join
  end

  def self.expired_at(doc)
    nil
  end

  def self.is_finish(doc)
    status = doc.at('//section[contains(@class, "section-title-group")]/div[contains(@class, "section-title-group__status")]')
    status.present? && status.text.include?("終了")
  end
end
