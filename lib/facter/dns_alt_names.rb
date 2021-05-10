Facter.add(:dns_alt_names) do
  setcode do
    if File.exist? '/etc/dns_alt_names'
      Facter::Util::Resolution.exec('cat /etc/dns_alt_names')
    end
  end
end
